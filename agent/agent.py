import os
import requests
import ollama
import json
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

BASE_URL = os.getenv("API_BASE_URL", "https://api.klampisdepo.com")
USERNAME = os.getenv("API_USERNAME", "admin")
PASSWORD = os.getenv("API_PASSWORD", "test123")
MODEL_NAME = os.getenv("OLLAMA_MODEL", "qwen3:8b")

token = None


def login():
    global token

    res = requests.post(
        f"{BASE_URL}/login",
        json={
            "username": USERNAME,
            "password": PASSWORD
        }
    )

    if res.status_code != 200:
        print("Login failed:", res.text)
        exit()

    data = res.json()
    token = data["token"]

    print("Login success")


def call_api(endpoint, data=None, method="POST", params=None):
    global token

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    url = f"{BASE_URL}/{endpoint}"
    
    if method == "POST":
        res = requests.post(url, headers=headers, json=data)
    elif method == "PUT":
        res = requests.put(url, headers=headers, json=data)
    elif method == "GET":
        res = requests.get(url, headers=headers, params=params)
    else:
        raise ValueError(f"Unsupported method: {method}")

    return {
        "status": res.status_code,
        "response": res.text
    }


def run_agent(user_input):
    system_prompt = """
Kamu adalah AI asisten toko.
Tugasmu adalah membantu user menambah stok barang atau membuat barang baru.

Jika user ingin menambah stok, gunakan action "add_stock".
Contoh: {"action": "add_stock", "name": "semen", "added_stock": 10}

Jika user ingin membuat barang baru, gunakan action "create_item".
Contoh: {"action": "create_item", "name": "semen", "price": 50000, "stock": 100}

Balas HANYA dalam format JSON. Jangan ada penjelasan lain.
"""

    print("Thinking...")
    response = ollama.chat(
        model=MODEL_NAME,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_input}
        ]
    )

    content = response["message"]["content"].strip()
    print(f"AI Responded: {content}")
    
    # Simple cleanup
    content = content.replace("```json", "").replace("```", "").strip()

    try:
        data = json.loads(content)

        if "message" in data:
            return data["message"]

        if data.get("action") == "add_stock":
            name = data["name"]
            added_stock = data.get("added_stock", 0)
            
            print(f"Searching for item: {name}...")
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res["status"] == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                
                if items:
                    item = items[0]
                    item_id = item["id"]
                    new_stock = item["stock"] + added_stock
                    
                    print(f"Found item. Updating stock to {new_stock}...")
                    update_payload = {
                        "name": item["name"],
                        "stock": new_stock,
                        "price": item["price"] # Keep price same if not provided
                    }
                    if data.get("price"): update_payload["price"] = data["price"]
                    
                    return call_api(f"items/{item_id}", update_payload, method="PUT")
                else:
                    return f"Item '{name}' tidak ditemukan."
            
            return f"Error searching item: {search_res['status']}"

        if data.get("action") == "create_item":
            print(f"Creating new item: {data['name']}...")
            payload = {
                "name": data["name"],
                "price": data["price"],
                "stock": data.get("stock", 0)
            }
            return call_api("items/", payload)

        return data

    except Exception as e:
        print(f"Parse error: {e}")
        return content


# ==== START ====
login()

while True:
    try:
        user_input = input(">> ")
        if not user_input.strip():
            continue
        print(run_agent(user_input))
    except (KeyboardInterrupt, EOFError):
        print("\nExiting...")
        break
    except Exception as e:
        print("Error:", e)