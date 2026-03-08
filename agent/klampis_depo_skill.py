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
Your task is to help users manage inventory items by updating stock, creating new items, modifying item properties, or checking for unusual manual stock changes.

### ACTIONS:
1. "add_stock": Add quantity to an existing item (e.g., "add 5 cement").
2. "create_item": Create a new item with complete information (name, price, buy_price, stock).
3. "update_item": Modify existing item properties like price or buy_price (e.g., "change aaaaa buy price to 5000").
4. "stock_changes": Retrieve manual stock adjustments for an item. Use when user wants to see decreases or increases not caused by sales/refunds (e.g., "show manual stock changes for aaaaa").
5. "audit_logs": Retrieve technical/administrative changes for an item (e.g., "show audit logs for aaaaa"). Use for creation, name changes, price changes, etc.
6. "transaction_history": Retrieve sales and refund history for an item (e.g., "show transactions for aaaaa").

Respond ONLY with valid JSON. Examples:
- {"action": "add_stock", "name": "cement", "added_stock": 5}
- {"action": "create_item", "name": "wood", "price": 50000, "buy_price": 30000, "stock": 0}
- {"action": "update_item", "name": "aaaaa", "buy_price": 5000}
- {"action": "stock_changes", "name": "aaaaa"}
- {"action": "audit_logs", "name": "aaaaa"}
- {"action": "transaction_history", "name": "aaaaa"}
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
                    new_stock = item["stock"] + added_stock
                    return f"📦 Stock for '{name}' increased by {added_stock} units. New stock: {new_stock}!"
                else:
                    if price is not None:
                        create_payload = {"name": name, "stock": added_stock, "price": price, "buy_price": buy_price or 0}
                        res = call_api("items/", create_payload, method="POST")
                        return f"🆕 New item '{name}' created with {added_stock} units in stock!"
                    return f"❌ Item '{name}' not found. Please provide price information."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if data.get("action") == "create_item":
            payload = {"name": data["name"], "price": data["price"], "stock": data.get("stock", 0), "buy_price": data.get("buy_price", 0)}
            res = call_api("items/", payload)
            return f"🆕 Item '{data['name']}' created successfully!"

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
                    return f"✅ Item '{name}' updated successfully!"
                else:
                    return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if data.get("action") == "stock_changes":
            name = data["name"]
            # find the item to get its ID
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                if items:
                    item = items[0]
                    inv_res = call_api("inventory/history", method="GET", params={"item_id": item["id"], "type": "adjustment"})
                    if inv_res.get("status") == 200:
                        changes = json.loads(inv_res["response"])
                        data_list = changes.get("data", [])
                        if not data_list:
                            return f"ℹ️ No manual stock changes found for '{name}'."
                        formatted = f"📊 Manual Stock Changes for '{name}':\n"
                        for change in data_list:
                            created_at = change.get("created_at", "")[:19]  # YYYY-MM-DDTHH:MM:SS
                            change_val = change.get("change", 0)
                            note = change.get("note", "")
                            formatted += f"🔄 {created_at}: {change_val} units ({note})\n"
                        return formatted
                    return f"❌ Failed to fetch stock changes. Status: {inv_res.get('status')}"
                return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if data.get("action") == "audit_logs":
            name = data["name"]
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                if items:
                    item = items[0]
                    audit_res = call_api("audit-logs/", method="GET", params={"entity_type": "item", "entity_id": item["id"]})
                    if audit_res.get("status") == 200:
                        logs_data = json.loads(audit_res["response"])
                        data_list = logs_data.get("data", [])
                        if not data_list:
                            return f"ℹ️ No audit logs found for '{name}'."
                        formatted = f"📋 Audit Logs for '{name}':\n"
                        for log_entry in data_list:
                            created_at = log_entry.get("created_at", "")[:19]
                            action = log_entry.get("action", "").upper()
                            desc = log_entry.get("description", "")
                            
                            # Parse detailed changes
                            changes_str = ""
                            changes = log_entry.get("changes")
                            old_value = log_entry.get("old_value")
                            new_value = log_entry.get("new_value")
                            
                            if changes:
                                try:
                                    changes_dict = json.loads(changes)
                                    change_details = []
                                    for field, change in changes_dict.items():
                                        if isinstance(change, dict) and "from" in change and "to" in change:
                                            change_details.append(f"{field}: {change['from']} → {change['to']}")
                                        elif isinstance(change, dict) and "old" in change and "new" in change:
                                            change_details.append(f"{field}: {change['old']} → {change['new']}")
                                        else:
                                            change_details.append(f"{field}: {change}")
                                    if change_details:
                                        changes_str = " | " + " | ".join(change_details)
                                except:
                                    pass
                            
                            # Fall back to old_value → new_value if changes not available
                            if not changes_str and old_value and new_value:
                                try:
                                    old_dict = json.loads(old_value)
                                    new_dict = json.loads(new_value)
                                    changes_detail = []
                                    for key in new_dict:
                                        if key not in old_dict or old_dict[key] != new_dict[key]:
                                            changes_detail.append(f"{key}: {old_dict.get(key, 'N/A')} → {new_dict[key]}")
                                    if changes_detail:
                                        changes_str = " | " + " | ".join(changes_detail)
                                except:
                                    pass
                            
                            formatted += f"🕒 {created_at} [{action}]: {desc}{changes_str}\n"
                        return formatted
                    return f"❌ Failed to fetch audit logs. Status: {audit_res.get('status')}"
                return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if data.get("action") == "transaction_history":
            name = data["name"]
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                if items:
                    item = items[0]
                    inv_res = call_api("inventory/history", method="GET", params={"item_id": item["id"]})
                    if inv_res.get("status") == 200:
                        hist_data = json.loads(inv_res["response"])
                        data_list = hist_data.get("data", [])
                        # Filter for sales/refunds
                        sales_refunds = [d for d in data_list if d.get("type") in ["sale", "refund"]]
                        if not sales_refunds:
                            return f"ℹ️ No transaction history (sales/refunds) found for '{name}'."
                        formatted = f"💰 Transaction History for '{name}':\n"
                        for entry in sales_refunds:
                            created_at = entry.get("created_at", "")[:19]
                            etype = entry.get("type", "").upper()
                            change = entry.get("change", 0)
                            note = entry.get("note", "")
                            formatted += f"🛒 {created_at} [{etype}]: {change} units ({note})\n"
                        return formatted
                    return f"❌ Failed to fetch transaction history. Status: {inv_res.get('status')}"
                return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        return content
    except Exception as e:
        return f"Error: {e} | Content: {content if 'content' in locals() else 'None'}"

if __name__ == "__main__":
    # Test execution
    print(handle_klampis_command("test 5"))
