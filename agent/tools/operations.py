import logging
from core.api_client import call_api
from tools.registry import registry

logger = logging.getLogger(__name__)

@registry.register("get_dashboard")
async def get_dashboard(data):
    res = await call_api("dashboard/", method="GET")
    if res.get("status") == 200:
        json_data = res.get("json", {})
        data_obj = json_data.get("data", {}) if isinstance(json_data, dict) else {}
        return (f"📊 **Shop Dashboard Summary**:\n"
                f"💰 Total Sales: Rp {data_obj.get('total_sales', 0):,}\n"
                f"📈 Total Profit: Rp {data_obj.get('total_profit', 0):,}\n"
                f"📦 Total Items: {data_obj.get('total_items', 0)}")
    return f"❌ Failed to fetch dashboard. Status: {res.get('status')}"

@registry.register("check_attendance")
async def check_attendance(data):
    history_mode = data.get("history", False)
    endpoint = "attendance/history" if history_mode else "attendance/today"
    
    res = await call_api(endpoint, method="GET")
    if res.get("status") == 200:
        json_res = res.get("json", {})
        records = json_res.get("data", []) if isinstance(json_res, dict) else []
        if not records: return f"ℹ️ No attendance records found."
        
        title = "Attendance History" if history_mode else "Today's Attendance"
        formatted = f"📅 **{title}**:\n"
        for r in records[:10]:
            name = r.get('user_name', 'Unknown')
            if history_mode:
                formatted += f"- {r.get('date', '')}: {name} ({r.get('status', '')})\n"
            else:
                formatted += f"- ✅ {name} at {r.get('check_in_time', '')[11:16]}\n"
        return formatted
    return f"❌ Failed to fetch attendance. Status: {res.get('status')}"

@registry.register("manage_cash")
async def manage_cash(data):
    res = await call_api("cash-sessions/current", method="GET")
    if res.get("status") == 200:
        json_res = res.get("json", {})
        session = json_res.get("data") if isinstance(json_res, dict) else None
        if not session: return "📂 Current cash session is **CLOSED**."
        return (f"💰 **Current Cash Session**:\n"
                f"🟢 Status: OPEN\n"
                f"👤 Opened by: {session.get('opened_by_name', 'Unknown')}\n"
                f"💵 Opening Balance: Rp {session.get('opening_balance', 0):,}\n"
                f"🕒 Opened at: {session.get('opened_at', '')[:19].replace('T', ' ')}")
    return f"❌ Failed to fetch cash session. Status: {res.get('status')}"

@registry.register("cash_session_history")
async def cash_session_history(data):
    res = await call_api("cash-sessions/history", method="GET")
    if res.get("status") == 200:
        json_res = res.get("json", {})
        sessions = json_res.get("data", []) if isinstance(json_res, dict) else []
        if not sessions: return "ℹ️ No cash session history found."
        formatted = "📂 **Cash Session History**:\n"
        for s in sessions[:10]:
            status = "✅ CLOSED" if s.get("closed_at") else "🟢 OPEN"
            f_at = (s.get("closed_at") or s.get("opened_at"))[:19].replace("T", " ")
            formatted += f"- {f_at} [{status}] | Balance: Rp {s.get('actual_balance', 0):,}\n"
        return formatted
    return f"❌ Failed to fetch cash history. Status: {res.get('status')}"

@registry.register("list_users")
async def list_users(data):
    res = await call_api("users/", method="GET")
    if res.get("status") == 200:
        json_res = res.get("json", {})
        users = json_res.get("data", []) if isinstance(json_res, dict) else []
        if not users: return "ℹ️ No users found."
        formatted = "👥 **Registered Users**:\n"
        for u in users:
            formatted += f"- {u.get('username', 'Unknown')} ({u.get('role', 'staff')})\n"
        return formatted
    return f"❌ Failed to fetch users. Status: {res.get('status')}"
