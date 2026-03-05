import os
import requests
import ollama
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

BASE_URL = os.getenv("API_BASE_URL", "https://api.klampisdepo.com")
USERNAME = os.getenv("API_USERNAME", "admin")
PASSWORD = os.getenv("API_PASSWORD", "test123")
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
Kamu adalah AI asisten toko yang pintar.
Tugasmu adalah membantu user mengelola stok barang (upsert: tambah stok jika ada, buat baru jika belum ada).

### STRATEGI:
1. "add_stock": Untuk tambah stok (misal: "tambah 10 semen").
2. "create_item": Untuk barang baru lengkap.
3. Cari field price/buy_price jika ada.

Balas HANYA JSON. Contoh: {"action": "add_stock", "name": "semen", "added_stock": 10}
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
                    update_payload = {"name": item["name"], "stock": item["stock"] + added_stock}
                    if price: update_payload["price"] = price
                    if buy_price: update_payload["buy_price"] = buy_price
                    res = call_api(f"items/{item['id']}", update_payload, method="PUT")
                    return f"Stok '{name}' berhasil diperbarui! Status: {res['status']}"
                else:
                    if price is not None:
                        create_payload = {"name": name, "stock": added_stock, "price": price, "buy_price": buy_price or 0}
                        res = call_api("items/", create_payload, method="POST")
                        return f"Barang baru '{name}' berhasil dibuat! Status: {res['status']}"
                    return f"Item '{name}' tidak ditemukan. Mohon berikan informasi harga."
            return "Gagal mencari item."

        if data.get("action") == "create_item":
            payload = {"name": data["name"], "price": data["price"], "stock": data.get("stock", 0), "buy_price": data.get("buy_price", 0)}
            res = call_api("items/", payload)
            return f"Barang '{data['name']}' berhasil dibuat! Status: {res['status']}"

        return content
    except Exception as e:
        return f"Error: {e} | Content: {content if 'content' in locals() else 'None'}"

if __name__ == "__main__":
    # Test execution
    print(handle_klampis_command("test 5"))
