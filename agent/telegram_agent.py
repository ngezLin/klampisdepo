import os
import logging
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, filters
from klampis_depo_skill import handle_klampis_command

# Load environment variables
load_dotenv()

TELEGRAM_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
ALLOWED_USER_IDS = [id.strip() for id in os.getenv("ALLOWED_USER_IDS", "").split(",") if id.strip()]

# Enable logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

def is_authorized(user_id):
    """Check if the user ID is in the allowed list."""
    if not ALLOWED_USER_IDS or "CHANGE_ME" in ALLOWED_USER_IDS:
        return False
    return str(user_id) in ALLOWED_USER_IDS

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for the /start command."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        logging.warning(f"Unauthorized access attempt by ID: {user_id}")
        await update.message.reply_text("Sorry, you don't have access to this bot. Please contact the administrator.")
        return

    await update.message.reply_text(
        "Hello! I'm Klampis Depo Bot. 🛒\n"
        "I can help you manage your inventory items.\n\n"
        "📝 **Command Examples:**\n"
        "• Add stock: \"add 5 cement\"\n"
        "• Create item: \"create new item wood price 50000 buy 30000\"\n"
        "• Update price: \"change aaaaa buy price to 5000\"\n"
        "• Update sell price: \"change aaaaa sell price to 100000\"\n\n"
        "Type /help for more information."
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for the /help command."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        return

    await update.message.reply_text(
        "📖 **Klampis Depo Bot - Command Guide**\n\n"
        "**1. Add Stock**\n"
        "   Usage: \"add 5 cement\"\n"
        "   Effect: Adds 5 units to cement if it exists, or creates it\n\n"
        "**2. Create New Item**\n"
        "   Usage: \"create wood price 50000 buy 30000\"\n"
        "   Usage: \"new item wood sell 50000 buy 30000\"\n"
        "   Effect: Creates a new item with name, sell price, and buy price\n\n"
        "**3. Update Buy Price**\n"
        "   Usage: \"change aaaaa buy price to 5000\"\n"
        "   Usage: \"update aaaaa buy 5000\"\n"
        "   Effect: Changes the buy price of item 'aaaaa' to 5000\n\n"
        "**4. Update Sell Price**\n"
        "   Usage: \"change aaaaa sell price to 100000\"\n"
        "   Usage: \"update aaaaa price 100000\"\n"
        "   Effect: Changes the sell price of item 'aaaaa' to 100000\n\n"
        "**5. Update Stock**\n"
        "   Usage: \"set aaaaa stock to 50\"\n"
        "   Effect: Sets the stock of item 'aaaaa' to 50 units\n\n"
        "Just send your commands in natural language. I'll understand! 😊"
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for processing natural language messages."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        logging.warning(f"Unauthorized message from ID: {user_id}")
        return

    user_text = update.message.text
    if not user_text:
        return

    # Show "typing..." action
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")

    # Use the existing logic from klampis_depo_skill
    response_text = handle_klampis_command(user_text)

    await update.message.reply_text(response_text)

if __name__ == '__main__':
    if not TELEGRAM_TOKEN:
        print("Error: TELEGRAM_BOT_TOKEN not found in .env")
        exit()

    application = ApplicationBuilder().token(TELEGRAM_TOKEN).build()
    
    start_handler = CommandHandler('start', start)
    help_handler = CommandHandler('help', help_command)
    msg_handler = MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message)

    application.add_handler(start_handler)
    application.add_handler(help_handler)
    application.add_handler(msg_handler)
    
    print("Bot is running...")
    application.run_polling()
