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
You are a smart shop management AI assistant for Klampis Depo.
Your task is to help users manage inventory items, transactions, and shop operations.

### INVENTORY COMMANDS:
1. "add_stock": Add quantity to an existing item (e.g., "add 5 cement").
2. "create_item": Create a new item (name, price, buy_price, stock).
3. "update_item": Modify existing item properties (price, buy_price, description).
4. "bulk_create_items": Create multiple items at once. (e.g., "bulk create items: wood 50000 30000, cement 60000 40000").
   Expected output format: {"action": "bulk_create_items", "items": [{"name": "wood", "price": 50000, "buy_price": 30000, "stock": 0}, ...]}
5. "export_items_csv": Export the entire inventory to a CSV file. (e.g., "export inventory to csv").
6. "low_stock_report": Identify items below a threshold (default 10).

### HISTORY & AUDIT COMMANDS:
7. "stock_changes": Retrieve manual adjustments for a specific item.
8. "audit_logs": Retrieve technical/administrative changes. 
   - If name is provided: {"action": "audit_logs", "name": "aaaaa"}
   - If no name: {"action": "audit_logs"} (shows all recent logs)
9. "transaction_history": Retrieve sales and refund history for an item.

### SHOP OPERATIONS COMMANDS:
10. "get_dashboard": Retrieve overall shop performance summary.
11. "check_attendance": Check today's attendance or history.
12. "manage_cash": Check current cash session status.
13. "cash_session_history": Show history of past cash sessions.
14. "list_users": List all registered users/employees.

Respond ONLY with valid JSON.
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

        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            return f"❌ Failed to parse AI response as JSON. Content: {content}"

        if "message" in data: return data["message"]

        action = data.get("action")

        if action == "add_stock":
            name, added_stock = data.get("name"), data.get("added_stock", 0)
            price, buy_price = data.get("price"), data.get("buy_price")

            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                
                if items:
                    item = items[0]
                    update_payload = {"name": item["name"], "stock": item["stock"] + added_stock, "price": item["price"], "buy_price": item["buy_price"]}
                    if "description" in item and item["description"]: update_payload["description"] = item["description"]
                    if "image_url" in item and item["image_url"]: update_payload["image_url"] = item["image_url"]
                    if price: update_payload["price"] = price
                    if buy_price: update_payload["buy_price"] = buy_price
                    res = call_api(f"items/{item['id']}", update_payload, method="PUT")
                    if res.get("status") == 200:
                        new_stock = item["stock"] + added_stock
                        return f"📦 Stock for '{name}' increased by {added_stock} units. New stock: {new_stock}!"
                    return f"❌ Failed to update stock. API Status: {res.get('status')} | {res.get('response')}"
                else:
                    if price is not None:
                        create_payload = {"name": name, "stock": added_stock, "price": price, "buy_price": buy_price or 0}
                        res = call_api("items/", create_payload, method="POST")
                        if res.get("status") in [200, 201]:
                            return f"🆕 New item '{name}' created with {added_stock} units in stock!"
                        return f"❌ Failed to create item. API Status: {res.get('status')} | {res.get('response')}"
                    return f"❌ Item '{name}' not found. Please provide price information."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if action == "create_item":
            payload = {"name": data["name"], "price": data["price"], "stock": data.get("stock", 0), "buy_price": data.get("buy_price", 0)}
            res = call_api("items/", payload)
            if res.get("status") in [200, 201]:
                return f"🆕 Item '{data['name']}' created successfully!"
            return f"❌ Failed to create item. Status: {res.get('status')} | {res.get('response')}"

        if action == "bulk_create_items":
            items_to_create = data.get("items", [])
            if not items_to_create:
                return "❌ No items found to create in bulk."
            res = call_api("items/bulk", items_to_create, method="POST")
            if res.get("status") in [200, 201]:
                created = json.loads(res["response"])
                return f"✅ Successfully created {len(created)} items in bulk!"
            return f"❌ Bulk creation failed. Status: {res.get('status')} | {res.get('response')}"

        if action == "export_items_csv":
            res = call_api("items/export/csv", method="GET")
            if res.get("status") == 200:
                # We can't send the file directly from here to Telegram yet, 
                # but we can save it or return the data. 
                # For now, let the agent handler know it's a file.
                return {"type": "file", "filename": "inventory_export.csv", "content": res["response"]}
            return f"❌ Export failed. Status: {res.get('status')}"

        if action == "update_item":
            name = data["name"]
            search_res = call_api("items/search", method="GET", params={"name": name})
            if search_res.get("status") == 200:
                results = json.loads(search_res["response"])
                items = results.get("data", [])
                if items:
                    item = items[0]
                    update_payload = {"name": item["name"], "stock": item["stock"], "price": item["price"], "buy_price": item["buy_price"]}
                    if "description" in item and item["description"]: update_payload["description"] = item["description"]
                    if "image_url" in item and item["image_url"]: update_payload["image_url"] = item["image_url"]
                    if "price" in data: update_payload["price"] = data["price"]
                    if "buy_price" in data: update_payload["buy_price"] = data["buy_price"]
                    if "stock" in data: update_payload["stock"] = data["stock"]
                    if "description" in data: update_payload["description"] = data["description"]
                    if "image_url" in data: update_payload["image_url"] = data["image_url"]
                    res = call_api(f"items/{item['id']}", update_payload, method="PUT")
                    if res.get("status") == 200:
                        return f"✅ Item '{name}' updated successfully!"
                    return f"❌ Failed to update item. Status: {res.get('status')}"
                else:
                    return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if action == "stock_changes":
            name = data["name"]
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
                            created_at = change.get("created_at", "")[:19].replace("T", " ")
                            change_val = change.get("change", 0)
                            note = change.get("note", "")
                            formatted += f"🔄 {created_at}: {change_val:+d} units ({note})\n"
                        return formatted
                    return f"❌ Failed to fetch stock changes. Status: {inv_res.get('status')}"
                return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if action == "audit_logs":
            name = data.get("name")
            params = {}
            if name:
                search_res = call_api("items/search", method="GET", params={"name": name})
                if search_res.get("status") == 200:
                    items = json.loads(search_res["response"]).get("data", [])
                    if items:
                        params = {"entity_type": "item", "entity_id": items[0]["id"]}
                    else:
                        return f"❌ Item '{name}' not found for audit logs."
            
            audit_res = call_api("audit-logs/", method="GET", params=params)
            if audit_res.get("status") == 200:
                logs_data = json.loads(audit_res["response"])
                data_list = logs_data.get("data", [])
                if not data_list:
                    return f"ℹ️ No audit logs found{' for ' + name if name else ''}."
                formatted = f"📋 Audit Logs{' (' + name + ')' if name else ''}:\n"
                for log_entry in data_list[:15]: # Limit to 15 entries
                    created_at = log_entry.get("created_at", "")[:19].replace("T", " ")
                    entry_action = log_entry.get("action", "").upper()
                    desc = log_entry.get("description", "")
                    
                    changes_str = ""
                    changes = log_entry.get("changes")
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
                        except: pass
                    
                    formatted += f"🕒 {created_at} [{entry_action}]: {desc}{changes_str}\n"
                return formatted
            return f"❌ Failed to fetch audit logs. Status: {audit_res.get('status')}"

        if action == "transaction_history":
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
                        sales_refunds = [d for d in data_list if d.get("type") in ["sale", "refund"]]
                        if not sales_refunds:
                            return f"ℹ️ No transaction history found for '{name}'."
                        formatted = f"💰 Transaction History for '{name}':\n"
                        for entry in sales_refunds:
                            created_at = entry.get("created_at", "")[:19].replace("T", " ")
                            etype = entry.get("type", "").upper()
                            change = entry.get("change", 0)
                            note = entry.get("note", "")
                            formatted += f"🛒 {created_at} [{etype}]: {change} units ({note})\n"
                        return formatted
                    return f"❌ Failed to fetch transaction history. Status: {inv_res.get('status')}"
                return f"❌ Item '{name}' not found."
            return "❌ Failed to search items. Please check your permissions or API connection."

        if action == "get_dashboard":
            res = call_api("dashboard/", method="GET")
            if res.get("status") == 200:
                data_obj = json.loads(res["response"]).get("data", {})
                return (f"📊 **Shop Dashboard Summary**:\n"
                        f"💰 Total Sales: Rp {data_obj.get('total_sales', 0):,}\n"
                        f"📈 Total Profit: Rp {data_obj.get('total_profit', 0):,}\n"
                        f"📦 Total Items: {data_obj.get('total_items', 0)}")
            return f"❌ Failed to fetch dashboard. Status: {res.get('status')}"

        if action == "check_attendance":
            if data.get("history"):
                res = call_api("attendance/history", method="GET")
                if res.get("status") == 200:
                    records = json.loads(res["response"]).get("data", [])
                    if not records: return "ℹ️ No attendance history found."
                    formatted = "📅 **Attendance History**:\n"
                    for r in records[:10]:
                        formatted += f"- {r.get('date', '')}: {r.get('user_name', 'Unknown')} ({r.get('status', '')})\n"
                    return formatted
            else:
                res = call_api("attendance/today", method="GET")
                if res.get("status") == 200:
                    records = json.loads(res["response"]).get("data", [])
                    if not records: return "ℹ️ No one has checked in today yet."
                    formatted = "👥 **Today's Attendance**:\n"
                    for r in records:
                        formatted += f"- ✅ {r.get('user_name', 'Unknown')} at {r.get('check_in_time', '')[11:16]}\n"
                    return formatted
            return f"❌ Failed to fetch attendance. Status: {res.get('status')}"

        if action == "manage_cash":
            res = call_api("cash-sessions/current", method="GET")
            if res.get("status") == 200:
                session = json.loads(res["response"]).get("data")
                if not session: return "📂 Current cash session is **CLOSED**."
                return (f"💰 **Current Cash Session**:\n"
                        f"🟢 Status: OPEN\n"
                        f"👤 Opened by: {session.get('opened_by_name', 'Unknown')}\n"
                        f"💵 Opening Balance: Rp {session.get('opening_balance', 0):,}\n"
                        f"🕒 Opened at: {session.get('opened_at', '')[:19].replace('T', ' ')}")
            return f"❌ Failed to fetch cash session. Status: {res.get('status')}"

        if action == "cash_session_history":
            res = call_api("cash-sessions/history", method="GET")
            if res.get("status") == 200:
                sessions = json.loads(res["response"]).get("data", [])
                if not sessions: return "ℹ️ No cash session history found."
                formatted = "📂 **Cash Session History**:\n"
                for s in sessions[:10]:
                    status = "✅ CLOSED" if s.get("closed_at") else "🟢 OPEN"
                    f_at = (s.get("closed_at") or s.get("opened_at"))[:19].replace("T", " ")
                    formatted += f"- {f_at} [{status}] | Balance: Rp {s.get('actual_balance', 0):,}\n"
                return formatted
            return f"❌ Failed to fetch cash history. Status: {res.get('status')}"

        if action == "list_users":
            res = call_api("users/", method="GET")
            if res.get("status") == 200:
                users = json.loads(res["response"]).get("data", [])
                if not users: return "ℹ️ No users found."
                formatted = "👥 **Registered Users**:\n"
                for u in users:
                    formatted += f"- {u.get('username', 'Unknown')} ({u.get('role', 'staff')})\n"
                return formatted
            return f"❌ Failed to fetch users. Status: {res.get('status')}"

        if action == "low_stock_report":
            threshold = data.get("threshold", 10)
            res = call_api("items/", method="GET")
            if res.get("status") == 200:
                items = json.loads(res["response"]).get("data", [])
                low_stock = [i for i in items if i.get("stock", 0) <= threshold]
                if not low_stock: return f"✅ All items have stock above {threshold}."
                formatted = f"⚠️ **Low Stock Report (Threshold: {threshold})**:\n"
                for i in low_stock:
                    formatted += f"- 📦 {i.get('name', 'Unknown')}: {i.get('stock', 0)} units left\n"
                return formatted
            return f"❌ Failed to fetch items. Status: {res.get('status')}"

        return content
    except Exception as e:
        return f"Error: {e} | Content: {content if 'content' in locals() else 'None'}"
    except Exception as e:
        return f"Error: {e} | Content: {content if 'content' in locals() else 'None'}"

if __name__ == "__main__":
    # Test execution
    print(handle_klampis_command("test 5"))
