import os
import logging
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters
from config import TELEGRAM_TOKEN
from bot.handlers import start, help_command, handle_message

# Enable logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

logger = logging.getLogger(__name__)

if __name__ == '__main__':
    if not TELEGRAM_TOKEN:
        logger.error("TELEGRAM_BOT_TOKEN not found in .env. Exiting...")
        exit()

    # Create the Telegram Application
    application = ApplicationBuilder().token(TELEGRAM_TOKEN).build()
    
    # Register command handlers
    start_handler = CommandHandler('start', start)
    help_handler = CommandHandler('help', help_command)
    
    # Register natural language message handler
    msg_handler = MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message)

    application.add_handler(start_handler)
    application.add_handler(help_handler)
    application.add_handler(msg_handler)
    
    logger.info("Bot is starting...")
    application.run_polling()
