from config import ALLOWED_USER_IDS, ADMIN_USER_IDS

def is_authorized(user_id: int) -> bool:
    """Check if the user ID is in the allowed list."""
    if not ALLOWED_USER_IDS or "CHANGE_ME" in ALLOWED_USER_IDS:
        return False
    return str(user_id) in ALLOWED_USER_IDS

def is_admin(user_id: int) -> bool:
    """Check if the user ID is in the admin list."""
    return str(user_id) in ADMIN_USER_IDS
