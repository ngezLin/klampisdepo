import httpx
import json
import logging
from typing import Any, Optional
from config import BASE_URL, USERNAME, PASSWORD
from thefuzz import fuzz, process

logger = logging.getLogger(__name__)

token = None

async def login():
    global token
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            res = await client.post(f"{BASE_URL}/login", json={"username": USERNAME, "password": PASSWORD})
            if res.status_code == 200:
                data = res.json()
                token = data.get("token")
                return True
    except Exception as e:
        logger.error(f"Login error: {e}")
    return False

async def call_api(endpoint: str, data: Any = None, method: str = "POST", params: Any = None):
    global token
    if not token and not await login():
        return {"error": "Authentication failed", "status": 401}

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = f"{BASE_URL}/{endpoint}"
    
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            if method == "POST":
                res = await client.post(url, headers=headers, json=data)
            elif method == "PUT":
                res = await client.put(url, headers=headers, json=data)
            elif method == "GET":
                res = await client.get(url, headers=headers, params=params)
            else:
                return {"error": f"Unsupported method: {method}", "status": 400}
            
            return {
                "status": res.status_code, 
                "response": res.text, 
                "json": res.json() if res.status_code == 200 and 'application/json' in res.headers.get('content-type', '') else None
            }
    except Exception as e:
        logger.error(f"API call error: {e}")
        return {"error": str(e), "status": 500}

async def fuzzy_match_item(name: str):
    """Attempt to find the closest matching item name if exact match fails."""
    res = await call_api("items/", method="GET")
    if res.get("status") == 200:
        data = res.get("json", {})
        items_data = data.get("data", []) if isinstance(data, dict) else []
        if not items_data:
            return None
        
        names = [item["name"] for item in items_data]
        match_info = process.extractOne(name, names, scorer=fuzz.token_sort_ratio)
        if match_info:
            match_name, score = match_info
            if score > 70:
                return next((item for item in items_data if item["name"] == match_name), None)
    return None
