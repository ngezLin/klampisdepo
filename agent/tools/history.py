import logging
from core.api_client import call_api
from tools.registry import registry

logger = logging.getLogger(__name__)

@registry.register("stock_changes")
async def stock_changes(data):
    name = data["name"]
    search_res = await call_api("items/search", method="GET", params={"name": name})
    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
            inv_res = await call_api("inventory/history", method="GET", params={"item_id": item["id"], "type": "adjustment"})
            if inv_res.get("status") == 200:
                hist_data = inv_res.get("json", {})
                changes = hist_data.get("data", []) if isinstance(hist_data, dict) else []
                if not changes: return f"ℹ️ No manual stock changes found for '{name}'."
                formatted = f"📊 Manual Stock Changes for '{name}':\n"
                for change in changes[:10]:
                    created_at = change.get("created_at", "")[:19].replace("T", " ")
                    formatted += f"🔄 {created_at}: {change.get('change', 0):+d} units ({change.get('note', '')})\n"
                return formatted
    return f"❌ Item '{name}' not found or search failed."

@registry.register("audit_logs")
async def audit_logs(data):
    name = data.get("name")
    params = {}
    if name:
        search_res = await call_api("items/search", method="GET", params={"name": name})
        if search_res.get("status") == 200:
            results = search_res.get("json", {})
            items = results.get("data", []) if isinstance(results, dict) else []
            if items:
                params = {"entity_type": "item", "entity_id": items[0]["id"]}
            else:
                return f"❌ Item '{name}' not found for audit logs."
    
    audit_res = await call_api("audit-logs/", method="GET", params=params)
    if audit_res.get("status") == 200:
        log_json = audit_res.get("json", {})
        logs_data = log_json.get("data", []) if isinstance(log_json, dict) else []
        if not logs_data: return f"ℹ️ No audit logs found{' for ' + name if name else ''}."
        formatted = f"📋 Audit Logs{' (' + name + ')' if name else ''}:\n"
        for log_entry in logs_data[:10]:
            created_at = log_entry.get("created_at", "")[:19].replace("T", " ")
            desc = log_entry.get("description", "")
            action = log_entry.get("action", "").upper()
            formatted += f"🕒 {created_at} [{action}]: {desc}\n"
        return formatted
    return f"❌ Failed to fetch audit logs. Status: {audit_res.get('status')}"

@registry.register("transaction_history")
async def transaction_history(data):
    name = data["name"]
    search_res = await call_api("items/search", method="GET", params={"name": name})
    if search_res.get("status") == 200:
        results = search_res.get("json", {})
        items = results.get("data", []) if isinstance(results, dict) else []
        if items:
            item = items[0]
            inv_res = await call_api("inventory/history", method="GET", params={"item_id": item["id"]})
            if inv_res.get("status") == 200:
                hist_json = inv_res.get("json", {})
                hist_data = hist_json.get("data", []) if isinstance(hist_json, dict) else []
                sales_refunds = [d for d in hist_data if d.get("type") in ["sale", "refund"]]
                if not sales_refunds: return f"ℹ️ No transaction history found for '{name}'."
                formatted = f"💰 Transaction History for '{name}':\n"
                for entry in sales_refunds[:10]:
                    created_at = entry.get("created_at", "")[:19].replace("T", " ")
                    type_str = entry.get("type", "").upper()
                    formatted += f"🛒 {created_at} [{type_str}]: {entry.get('change', 0)} units ({entry.get('note', '')})\n"
                return formatted
    return f"❌ Item '{name}' not found or search failed."
