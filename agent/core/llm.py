import json
import logging
import ollama
from typing import Any, Dict, List
from config import MODEL_NAME
from core.memory import session_manager
from tools.registry import registry

# Import tools so they register with the registry
import tools.inventory
import tools.history
import tools.operations

logger = logging.getLogger(__name__)

# Initialize Ollama client
client = ollama.AsyncClient()

SYSTEM_PROMPT = """
You are a smart shop management AI assistant for Klampis Depo.
Your task is to help users manage inventory items, transactions, and shop operations.

### CORE PRINCIPLES:
1.  **Conversational**: If a user is just saying hello or asking a general question, respond politely.
2.  **Tool-Oriented**: For actions, output ONLY valid JSON.
3.  **Context-Aware**: Use the conversation history to handle follow-up questions.

### TOOL DEFINITIONS:
-   `add_stock`: {"action": "add_stock", "name": "item_name", "added_stock": 10}
-   `create_item`: {"action": "create_item", "name": "item_name", "price": 50000, "buy_price": 30000, "stock": 10}
-   `update_item`: {"action": "update_item", "name": "item_name", "price": 60000}
-   `bulk_create_items`: {"action": "bulk_create_items", "items": [{"name": "wood", "price": 50000, "buy_price": 30000, "stock": 0}, ...]}
-   `export_items_csv`: {"action": "export_items_csv"}
-   `low_stock_report`: {"action": "low_stock_report", "threshold": 10}
-   `stock_changes`: {"action": "stock_changes", "name": "item_name"}
-   `audit_logs`: {"action": "audit_logs", "name": "optional_item_name"}
-   `transaction_history`: {"action": "transaction_history", "name": "item_name"}
-   `get_dashboard`: {"action": "get_dashboard"}
-   `check_attendance`: {"action": "check_attendance", "history": false}
-   `manage_cash`: {"action": "manage_cash"}
-   `cash_session_history`: {"action": "cash_session_history"}
-   `list_users`: {"action": "list_users"}

### EXAMPLES:
User: "Hi there!"
Assistant: {"message": "Hello! I'm your Klampis Depo assistant. How can I help you manage the shop today?"}

User: "Add 10 semen"
Assistant: {"action": "add_stock", "name": "semen", "added_stock": 10}

User: "What about the price?" (Follow-up)
Assistant: {"message": "I'm sorry, which item are you referring to? You recently added stock for 'semen'."}

User: "Yes, for semen."
Assistant: {"message": "The current price for 'semen' is in the system. Would you like to change it?"}

Actually, change the price of wood to 55k"
Assistant: {"action": "update_item", "name": "wood", "price": 55000}

Respond ONLY with valid JSON.
"""

async def handle_klampis_command(user_input: str, user_id: str = "default"):
    """
    Handles natural language commands by:
    1. Retrieving conversation history.
    2. Calling Ollama.
    3. Parsing the response.
    4. Executing the appropriate tool or returning a message.
    """
    history = session_manager.get_history(user_id)
    messages = [{"role": "system", "content": SYSTEM_PROMPT}] + history + [{"role": "user", "content": user_input}]

    try:
        response = await client.chat(
            model=MODEL_NAME,
            messages=messages,
            format="json"
        )
        content = response["message"]["content"].strip()
        
        try:
            data = json.loads(content)
        except json.JSONDecodeError:
            # Fallback if JSON parsing fails despite response_format
            logger.error(f"Failed to parse JSON response: {content}")
            session_manager.add_message(user_id, "user", user_input)
            session_manager.add_message(user_id, "assistant", content)
            return content

        # Update history
        session_manager.add_message(user_id, "user", user_input)
        session_manager.add_message(user_id, "assistant", content)

        if "message" in data:
            return data["message"]

        action = data.get("action")
        if action:
            return await registry.execute(action, data)
        
        return content

    except Exception as e:
        logger.error(f"LLM processing error: {e}")
        return f"❌ An error occurred while processing your request: {str(e)}"
