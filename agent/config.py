import os
from dotenv import load_dotenv

load_dotenv()

# API Configuration
BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8080/api")
USERNAME = os.getenv("API_USERNAME", "admin")
PASSWORD = os.getenv("API_PASSWORD", "admin123")

# LLM Configuration
MODEL_NAME = os.getenv("OLLAMA_MODEL", "qwen3:8b")
VISION_MODEL = os.getenv("VISION_MODEL", "moondream")

# Telegram Configuration
TELEGRAM_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
ALLOWED_USER_IDS = [id.strip() for id in os.getenv("ALLOWED_USER_IDS", "").split(",") if id.strip()]
ADMIN_USER_IDS = [id.strip() for id in os.getenv("ADMIN_USER_IDS", "").split(",") if id.strip()] or ALLOWED_USER_IDS
