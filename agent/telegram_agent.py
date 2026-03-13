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
ADMIN_USER_IDS = [id.strip() for id in os.getenv("ADMIN_USER_IDS", "").split(",") if id.strip()] or ALLOWED_USER_IDS

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

def is_admin(user_id):
    """Check if the user ID is in the admin list."""
    return str(user_id) in ADMIN_USER_IDS

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for the /start command."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        logging.warning(f"Unauthorized access attempt by ID: {user_id}")
        await update.message.reply_text("Sorry, you don't have access to this bot. Please contact the administrator.")
        return

    await update.message.reply_text(
        "👋 Hello! I'm Klampis Depo Bot, your smart shop assistant.\n\n"
        "I can help you manage inventory, check sales, and monitor operations using natural language.\n\n"
        "💡 **Not sure where to start?**\n"
        "Try saying: \"How is the shop doing today?\" or \"Add 10 units of cement\".\n\n"
        "Type /help to see all available commands categorized by function."
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for the /help command."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        return

    help_text = (
        "📖 **Klampis Depo Bot - Command Guide**\n\n"
        "**📦 INVENTORY MANAGEMENT**\n"
        "• **Add Stock**: \"add 5 cement\"\n"
        "• **Create Item**: \"create wood price 50000 buy 30000\"\n"
        "• **Bulk Create**: \"bulk create: wood 50000 30000, cement 60000 40000\"\n"
        "• **Update Item**: \"change cement price to 55000\"\n"
        "• **Export CSV**: \"export inventory to csv\"\n"
        "• **Low Stock**: \"show items with low stock\"\n\n"
        "**📊 HISTORY & AUDIT**\n"
        "• **Manual Changes**: \"show manual stock changes for cement\"\n"
        "• **Audit Logs**: \"show audit logs for cement\" or \"show global audit logs\"\n"
        "• **Transactions**: \"show sales history for wood\"\n\n"
        "**🏢 SHOP OPERATIONS**\n"
        "• **Dashboard**: \"show shop summary\" or \"how is the shop doing?\"\n"
        "• **Attendance**: \"who is working today?\" or \"show attendance history\"\n"
        "• **Cash Session**: \"is the cash drawer open?\" or \"show cash history\"\n"
        "• **User List**: \"list all employees\"\n\n"
        "💡 *Tips: I understand various phrasings, so feel free to talk to me naturally!*"
    )
    
    await update.message.reply_text(help_text, parse_mode='Markdown')

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
    response = handle_klampis_command(user_text)

    if isinstance(response, dict) and response.get("type") == "file":
        # Handle file export
        import io
        file_content = response.get("content", "")
        filename = response.get("filename", "export.csv")
        
        # Admin check for exports
        if not is_admin(user_id):
            await update.message.reply_text("❌ You don't have permission to export data.")
            return

        file_obj = io.BytesIO(file_content.encode('utf-8'))
        file_obj.name = filename
        
        await update.message.reply_document(
            document=file_obj,
            filename=filename,
            caption="📊 Here is your inventory export."
        )
    else:
        # Standard text response
        await update.message.reply_text(response, parse_mode='Markdown')

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
