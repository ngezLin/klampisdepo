import logging
import io
from telegram import Update
from telegram.ext import ContextTypes
from bot.auth import is_authorized, is_admin
from core.llm import handle_klampis_command

logger = logging.getLogger(__name__)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for the /start command."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        logger.warning(f"Unauthorized access attempt by ID: {user_id}")
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
        logger.warning(f"Unauthorized message from ID: {user_id}")
        return

    user_text = update.message.text
    if not user_text:
        return

    # Show "typing..." action
    await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")

    # Use the handle_klampis_command from our core/llm model
    response = await handle_klampis_command(user_text, user_id=str(user_id))

    if isinstance(response, dict) and response.get("type") == "file":
        # Handle file export (like CSV)
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
        # Using Markdown for parsing if possible
        try:
            await update.message.reply_text(response, parse_mode='Markdown')
        except Exception:
            # Fallback to plain text if Markdown fails (e.g., due to unescaped special characters)
            await update.message.reply_text(response)
