import json
import logging
from core.api_client import call_api, fuzzy_match_item
from tools.registry import registry

logger = logging.getLogger(__name__)

@registry.register("add_stock")
async def add_stock(data):
    name, added_stock = data.get("name"), data.get("added_stock", 0)
    price, buy_price = data.get("price"), data.get("buy_price")

    search_res = await call_api("items/search", method="GET", params={"name": name})
    item = None
    
    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
    
    if not item:
        item = await fuzzy_match_item(name)
        if item:
            logger.info(f"Fuzzy matched '{name}' to '{item['name']}' for add_stock")

    if item:
        new_stock = item["stock"] + added_stock
        update_payload = {
            "name": item["name"], 
            "stock": int(new_stock), 
            "price": float(price or item["price"]), 
            "buy_price": float(buy_price or item["buy_price"]),
            "description": item.get("description", ""),
            "image_url": item.get("image_url", "")
        }
        
        res = await call_api(f"items/{item['id']}", update_payload, method="PUT")
        if res.get("status") == 200:
            return f"📦 Stock for '{item['name']}' increased by {added_stock} units. New stock: {new_stock}!"
        return f"❌ Failed to update stock. API Status: {res.get('status')}"
    else:
        if price is not None:
            create_payload = {"name": name, "stock": added_stock, "price": price, "buy_price": buy_price or 0}
            res = await call_api("items/", create_payload, method="POST")
            if res.get("status") in [200, 201]:
                return f"🆕 New item '{name}' created with {added_stock} units in stock!"
            return f"❌ Failed to create item. Status: {res.get('status')}"
        return f"❌ Item '{name}' not found. Please provide price information to create it."

@registry.register("create_item")
async def create_item(data):
    payload = {
        "name": data["name"], 
        "price": data["price"], 
        "stock": data.get("stock", 0), 
        "buy_price": data.get("buy_price", 0)
    }
    res = await call_api("items/", payload)
    if res.get("status") in [200, 201]:
        return f"🆕 Item '{data['name']}' created successfully!"
    return f"❌ Failed to create item. Status: {res.get('status')}"

@registry.register("bulk_create_items")
async def bulk_create_items(data):
    items_to_create = data.get("items", [])
    if not items_to_create:
        return "❌ No items found to create in bulk."
    res = await call_api("items/bulk", items_to_create, method="POST")
    if res.get("status") in [200, 201]:
        return f"✅ Successfully created {len(items_to_create)} items in bulk!"
    return f"❌ Bulk creation failed. Status: {res.get('status')}"

@registry.register("export_items_csv")
async def export_items_csv(data):
    res = await call_api("items/export/csv", method="GET")
    if res.get("status") == 200:
        return {"type": "file", "filename": "inventory_export.csv", "content": res["response"]}
    return f"❌ Export failed. Status: {res.get('status')}"

@registry.register("update_item")
async def update_item(data):
    name = data["name"]
    search_res = await call_api("items/search", method="GET", params={"name": name})
    item = None

    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
    
    if not item:
        item = await fuzzy_match_item(name)
        if item:
            logger.info(f"Fuzzy matched '{name}' to '{item['name']}' for update")

    if item:
        update_payload = {
            "name": item["name"], 
            "stock": data.get("stock", item["stock"]), 
            "price": data.get("price", item["price"]), 
            "buy_price": data.get("buy_price", item["buy_price"]),
            "description": data.get("description", item.get("description", "")),
            "image_url": data.get("image_url", item.get("image_url", ""))
        }
        
        res = await call_api(f"items/{item['id']}", update_payload, method="PUT")
        if res.get("status") == 200:
            return f"✅ Item '{item['name']}' updated successfully!"
        return f"❌ Failed to update item. Status: {res.get('status')}"
    return f"❌ Item '{name}' not found."

@registry.register("low_stock_report")
async def low_stock_report(data):
    threshold = data.get("threshold", 10)
    res = await call_api("items/", method="GET")
    if res.get("status") == 200:
        json_res = res.get("json", {})
        items = json_res.get("data", []) if isinstance(json_res, dict) else []
        low_stock = [i for i in items if i.get("stock", 0) <= threshold]
        if not low_stock: return f"✅ All items have stock above {threshold}."
        formatted = f"⚠️ **Low Stock Report (Threshold: {threshold})**:\n"
        for i in low_stock:
            formatted += f"- 📦 {i.get('name', 'Unknown')}: {i.get('stock', 0)} units left\n"
        return formatted
    return f"❌ Failed to fetch items. Status: {res.get('status')}"

@registry.register("delete_item")
async def delete_item(data):
    name = data.get("name")
    if not name:
        return "❌ Please provide the name of the item to delete."

    search_res = await call_api("items/search", method="GET", params={"name": name})
    item = None
    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
            
    if not item:
        item = await fuzzy_match_item(name)
        
    if item:
        res = await call_api(f"items/{item['id']}", method="DELETE")
        if res.get("status") in [200, 204]:
            return f"🗑️ Item '{item['name']}' has been deleted successfully."
        return f"❌ Failed to delete item. Status: {res.get('status')}"
    return f"❌ Item '{name}' not found."

@registry.register("get_item_details")
async def get_item_details(data):
    name = data.get("name")
    if not name:
        return "❌ Please provide the name of the item to check."

    search_res = await call_api("items/search", method="GET", params={"name": name})
    item = None
    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
            
    if not item:
        item = await fuzzy_match_item(name)
        
    if item:
        stock = item.get("stock", 0)
        price = item.get("price", 0)
        buy_price = item.get("buy_price", 0)
        desc = item.get("description", "No description available.")
        
        formatted = f"📦 **Item Details: {item['name']}**\n"
        formatted += f"• **Current Stock**: {stock} units\n"
        formatted += f"• **Selling Price**: Rp {price:,.0f}\n"
        formatted += f"• **Buying Price**: Rp {buy_price:,.0f}\n"
        formatted += f"• **Description**: {desc}\n"
        return formatted
    
    return f"❌ Item '{name}' not found."
