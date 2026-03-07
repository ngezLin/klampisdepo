import os
import requests
import ollama
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

BASE_URL = os.getenv("API_BASE_URL")
USERNAME = os.getenv("API_USERNAME")
PASSWORD = os.getenv("API_PASSWORD")
MODEL_NAME = os.getenv("OLLAMA_MODEL", "qwen3:8b")

token = None

def login():
    global token
    try:
        res = requests.post(f"{BASE_URL}/login", json={"username": USERNAME, "password": PASSWORD})
        if res.status_code == 200:
            token = res.json()["token"]
            return True
    except Exception as e:
        print(f"Login error: {e}")
    return False

def call_api(endpoint, data=None, method="POST", params=None):
    global token
    if not token and not login():
        return {"error": "Authentication failed"}

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = f"{BASE_URL}/{endpoint}"
    
    try:
        if method == "POST":
            res = requests.post(url, headers=headers, json=data)
        elif method == "PUT":
            res = requests.put(url, headers=headers, json=data)
        elif method == "GET":
            res = requests.get(url, headers=headers, params=params)
        return {"status": res.status_code, "response": res.text}
    except Exception as e:
        return {"error": str(e)}

def handle_klampis_command(user_input):
    """
    Main entry point for the OpenClaw skill.
    This replaces the 'run_agent' loop with a clean function call.
    """
    system_prompt = """
You are a smart shop management AI assistant.
Your task is to help users manage inventory items by updating stock, creating new items, or modifying item properties.

### ACTIONS:
1. "add_stock": Add quantity to an existing item (e.g., "add 5 cement").
2. "create_item": Create a new item with complete information (name, price, buy_price, stock).
3. "update_item": Modify existing item properties like price or buy_price (e.g., "change aaaaa buy price to 5000").

Respond ONLY with valid JSON. Examples:
- {"action": "add_stock", "name": "cement", "added_stock": 5}
- {"action": "create_item", "name": "wood", "price": 50000, "buy_price": 30000, "stock": 0}
- {"action": "update_item", "name": "aaaaa", "buy_price": 5000}
"""

    try:
        response = ollama.chat(
            model=MODEL_NAME,
            messages=[{"role": "system", "content": system_prompt}, {"role": "user", "content": user_input}]
        )
        content = response["message"]["content"].strip()
        
        # Clean markdown
        if content.startswith("```json"): content = content[7:-3].strip()
        elif content.startswith("```"): content = content[3:-3].strip()

        data = json.loads(content)
        if "message" in data: return data["message"]

        if data.get("action") == "add_stock":
            name, added_stock = data["name"], data.get("added_stock", 0)
            price, buy_price = data.get("price"), data.get("buy_price")

            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                
                if items:
                    item = items[0]
                    # Preserve all existing fields
                    update_payload = {"name": item["name"], "stock": item["stock"] + added_stock, "price": item["price"], "buy_price": item["buy_price"]}
                    if "description" in item and item["description"]: update_payload["description"] = item["description"]
                    if "image_url" in item and item["image_url"]: update_payload["image_url"] = item["image_url"]
                    if price: update_payload["price"] = price
                    if buy_price: update_payload["buy_price"] = buy_price
                    res = call_api(f"items/{item['id']}", update_payload, method="PUT")
                    return f"Stock '{name}' updated successfully! Status: {res['status']}"
                else:
                    if price is not None:
                        create_payload = {"name": name, "stock": added_stock, "price": price, "buy_price": buy_price or 0}
                        res = call_api("items/", create_payload, method="POST")
                        return f"New item '{name}' created successfully! Status: {res['status']}"
                    return f"Item '{name}' not found. Please provide price information."
            return "Failed to search items."

        if data.get("action") == "create_item":
            payload = {"name": data["name"], "price": data["price"], "stock": data.get("stock", 0), "buy_price": data.get("buy_price", 0)}
            res = call_api("items/", payload)
            return f"Item '{data['name']}' created successfully! Status: {res['status']}"

        if data.get("action") == "update_item":
            name = data["name"]
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                if items:
                    item = items[0]
                    # Preserve all existing fields, then override with new values
                    update_payload = {"name": item["name"], "stock": item["stock"], "price": item["price"], "buy_price": item["buy_price"]}
                    if "description" in item and item["description"]: update_payload["description"] = item["description"]
                    if "image_url" in item and item["image_url"]: update_payload["image_url"] = item["image_url"]
                    if "price" in data: update_payload["price"] = data["price"]
                    if "buy_price" in data: update_payload["buy_price"] = data["buy_price"]
                    if "stock" in data: update_payload["stock"] = data["stock"]
                    if "description" in data: update_payload["description"] = data["description"]
                    if "image_url" in data: update_payload["image_url"] = data["image_url"]
                    res = call_api(f"items/{item['id']}", update_payload, method="PUT")
                    return f"Item '{name}' updated successfully! Status: {res['status']}"
                else:
                    return f"Item '{name}' not found."
            return "Failed to search items."

        return content
    except Exception as e:
        return f"Error: {e} | Content: {content if 'content' in locals() else 'None'}"

if __name__ == "__main__":
    # Test execution
    print(handle_klampis_command("test 5"))
