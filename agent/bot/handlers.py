import json
import logging
import io
import os
import tempfile
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ContextTypes
from bot.auth import is_authorized, is_admin
from core.llm import handle_klampis_command
from core.vision import get_receipt_data
from tools.inventory import add_stock

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
        "**📸 RECEIPT RECOGNITION**\n"
        "• **Scan Receipt**: Send a photo of a vendor receipt. I'll automatically detect items and ask for confirmation before adding them to stock.\n\n"
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

async def handle_receipt_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for processing receipt photos."""
    user_id = update.effective_user.id
    if not is_authorized(user_id):
        return

    photo_file = await update.message.photo[-1].get_file()
    
    # Create a temporary directory to store the photo
    with tempfile.TemporaryDirectory() as tmp_dir:
        photo_path = os.path.join(tmp_dir, f"receipt_{user_id}.jpg")
        await photo_file.download_to_drive(photo_path)

        # Show "thinking" action
        await context.bot.send_chat_action(chat_id=update.effective_chat.id, action="typing")
        
        # Analyze receipt
        result = await get_receipt_data(photo_path)
        
        if "error" in result:
            await update.message.reply_text(f"❌ Error analyzing receipt: {result['error']}")
            return

        # Store result for confirmation
        context.user_data['pending_receipt'] = result
        
        # Format summary
        vendor = result.get("vendor", "Unknown")
        items = result.get("items", [])
        
        summary = f"📋 **Receipt Summary**\n🏪 **Vendor:** {vendor}\n\n**Items Found:**\n"
        for i in items:
            summary += f"- {i.get('name')}: {i.get('quantity')} units (@{i.get('price', 0):,})\n"
        
        summary += "\nShould I add these items to the inventory?"

        keyboard = [
            [
                InlineKeyboardButton("✅ Confirm", callback_data="receipt_confirm"),
                InlineKeyboardButton("❌ Cancel", callback_data="receipt_cancel")
            ]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        
        await update.message.reply_text(summary, reply_markup=reply_markup, parse_mode='Markdown')

async def receipt_callback_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handler for confirm/cancel buttons on receipt summary."""
    query = update.callback_query
    await query.answer()
    
    user_id = query.from_user.id
    action = query.data
    
    if action == "receipt_cancel":
        context.user_data.pop('pending_receipt', None)
        await query.edit_message_text("❌ Receipt processing cancelled.")
        return

    receipt_data = context.user_data.pop('pending_receipt', None)
    if not receipt_data:
        await query.edit_message_text("❌ No pending receipt data found.")
        return

    await query.edit_message_text("⏳ Processing inventory updates...")
    
    items = receipt_data.get("items", [])
    results = []
    
    for item in items:
        # Prepare data for add_stock tool
        tool_data = {
            "name": item.get("name"),
            "added_stock": item.get("quantity", 1),
            "price": item.get("price"),
            "buy_price": item.get("price") # Assuming buy price equals receipt price
        }
        
        # Call the existing add_stock tool logic
        res = await add_stock(tool_data)
        results.append(res)
    
    final_report = "✅ **Inventory Updated From Receipt:**\n\n" + "\n".join(results)
    
    # Truncate if too long (Telegram limit)
    if len(final_report) > 4000:
        final_report = final_report[:3997] + "..."
        
    await query.edit_message_text(final_report, parse_mode='Markdown')
