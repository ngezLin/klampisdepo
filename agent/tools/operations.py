import logging
from core.api_client import call_api
from tools.registry import registry

logger = logging.getLogger(__name__)

@registry.register("get_dashboard")
async def get_dashboard(data):
    res = await call_api("dashboard/", method="GET")
    if res.get("status") == 200:
        data_obj = res.get("json", {})
        if not isinstance(data_obj, dict):
            data_obj = {}
            
        today_omzet = data_obj.get('today_omzet', 0)
        today_profit = data_obj.get('today_profit', 0)
        today_tx = data_obj.get('today_transactions', 0)
        low_stock = data_obj.get('low_stock', 0)
        
        return (f"📊 **Shop Dashboard Overview (Today)**:\n"
                f"💰 Today's Sales: Rp {today_omzet:,}\n"
                f"📈 Today's Profit: Rp {today_profit:,}\n"
                f"🧾 Today's Transactions: {today_tx}\n"
                f"⚠️ Low Stock Items: {low_stock}")
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

@registry.register("mark_attendance")
async def mark_attendance(data):
    status = data.get("status", "clock_in")
    res = await call_api("attendance/", {"status": status}, method="POST")
    if res.get("status") in [200, 201]:
        status_text = "Clocked In" if status == "clock_in" else "Clocked Out"
        return f"✅ Attendance marked: **{status_text}** successfully!"
    return f"❌ Failed to mark attendance. Status: {res.get('status')}"

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

@registry.register("open_cash_session")
async def open_cash_session(data):
    opening_balance = data.get("opening_balance", 0)
    res = await call_api("cash-sessions/open", {"opening_balance": opening_balance}, method="POST")
    if res.get("status") in [200, 201]:
        return f"🟢 Cash session **OPENED** with balance: Rp {opening_balance:,}"
    return f"❌ Failed to open cash session. Status: {res.get('status')}"

@registry.register("close_cash_session")
async def close_cash_session(data):
    actual_balance = data.get("actual_balance", 0)
    res = await call_api("cash-sessions/close", {"actual_balance": actual_balance}, method="POST")
    if res.get("status") in [200, 201]:
        return f"✅ Cash session **CLOSED** with final balance: Rp {actual_balance:,}"
    return f"❌ Failed to close cash session. Status: {res.get('status')}"

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
