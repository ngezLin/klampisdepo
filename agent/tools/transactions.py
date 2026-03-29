import logging
from core.api_client import call_api
from tools.registry import registry

logger = logging.getLogger(__name__)

@registry.register("list_transactions")
async def list_transactions(data):
    limit = data.get("limit", 10)
    res = await call_api("transactions/", method="GET", params={"limit": limit})
    if res.get("status") == 200:
        json_res = res.get("json", {})
        transactions = json_res.get("data", []) if isinstance(json_res, dict) else []
        if not transactions: return "ℹ️ No recent transactions found."
        
        formatted = f"🧾 **Recent Transactions (Last {len(transactions)})**:\n"
        for tx in transactions:
            created_at = tx.get("created_at", "")[:19].replace("T", " ")
            total = tx.get("total", 0)
            status = tx.get("status", "completed").upper()
            formatted += f"- {created_at} | ID: `{tx.get('id')}` | Rp {total:,.0f} [{status}]\n"
        return formatted
    return f"❌ Failed to fetch transactions. Status: {res.get('status')}"

@registry.register("refund_transaction")
async def refund_transaction(data):
    tx_id = data.get("transaction_id")
    if not tx_id:
        return "❌ Please provide a transaction ID to refund."
        
    res = await call_api(f"transactions/{tx_id}/refund", method="POST")
    if res.get("status") == 200:
        return f"✅ Transaction `{tx_id}` has been successfully refunded!"
    elif res.get("status") == 404:
        return f"❌ Transaction `{tx_id}` not found."
    return f"❌ Failed to refund transaction. Status: {res.get('status')}"
