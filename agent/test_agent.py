import asyncio
import logging
from core.llm import handle_klampis_command
from config import MODEL_NAME

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def run_tests():
    print(f"🚀 Testing Klampis Depo Agent with model: {MODEL_NAME}\n")
    
    test_cases = [
        "Hi, how are you?",
        "Add 10 semen price 50000",
        "Open cash session with 150000",
        "Mark attendance clock in",
        "Refund transaction 12345",
        "Show recent transactions"
    ]
    
    for i, cmd in enumerate(test_cases, 1):
        print(f"--- Test Case {i}: '{cmd}' ---")
        try:
            # We bypass the actual tool execution in the output for now 
            # by looking at what handle_klampis_command returns.
            # Note: If API is not running, tool execution will fail, but LLM reasoning will be visible.
            response = await handle_klampis_command(cmd)
            print(f"Assistant Response:\n{response}\n")
        except Exception as e:
            print(f"❌ Error during test: {e}\n")

if __name__ == "__main__":
    asyncio.run(run_tests())
