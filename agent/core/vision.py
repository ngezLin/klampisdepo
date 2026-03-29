import base64
import json
import logging
from typing import Dict, Any
import ollama
from config import MODEL_NAME

logger = logging.getLogger(__name__)

# Initialize Ollama client
client = ollama.AsyncClient()

VISION_PROMPT = """
Analyze this receipt image and extract the following information in a structured JSON format:
- vendor: Name of the store or vendor.
- date: Date of the transaction (if available).
- items: A list of items, where each item has:
    - name: Name of the item.
    - quantity: Number of units (default to 1 if not clear).
    - price: Unit price (if available, else 0).

Respond ONLY with valid JSON.
"""

async def get_receipt_data(image_path: str) -> Dict[str, Any]:
    """
    Analyzes a receipt image using Ollama (moondream) and returns extracted data.
    """
    try:
        with open(image_path, "rb") as image_file:
            image_bytes = image_file.read()

        response = await client.chat(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "user",
                    "content": VISION_PROMPT,
                    "images": [image_bytes]
                }
            ],
            format="json"
        )

        content = response["message"]["content"].strip()
        return json.loads(content)

    except Exception as e:
        logger.error(f"Vision processing error: {e}")
        return {"error": str(e)}
