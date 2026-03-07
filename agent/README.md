# Klampis Depo - AI Stock Agent

This agent allows you to manage inventory stock using natural language. It can automatically detect whether to update existing stock or create a new item based on your input.

## Features

- **Stock Upsert**: Add stock to existing items or create new ones if not found (with price).
- **Manual Stock Change Query**: Ask the bot to show adjustments not caused by transactions (e.g., "show manual stock changes for aaaaa").
- **Natural Language Parsing**: Uses Ollama (`qwen3:8b`) to understand commands like "tambah 5 semen tiga roda".
- **Production Ready**: Uses environment variables for configuration and handles AI response quirks gracefully.
- **OpenClaw Integration**: Multi-platform support (Telegram, WhatsApp, Discord) via the included skill script.

## Setup

1. **Install dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

2. **Configure Environment**:
   Create a `.env` file in this directory based on the following template:

   ```env
   API_BASE_URL=https://api.yourdomain.com
   API_USERNAME=your_username
   API_PASSWORD=your_password
   OLLAMA_MODEL=qwen3:8b
   ```

3. **Run Locally**:
   ```bash
   python agent.py
   ```

## OpenClaw Integration

To use this agent with Telegram/WhatsApp/Discord:

1. Copy `klampis_depo_skill.py` to your OpenClaw `skills` directory.
2. Add the corresponding `skill.yaml` to register it.
3. Configure your gateway tokens in OpenClaw.

## Files

- `agent.py`: Interactive CLI version of the agent.
- `klampis_depo_skill.py`: Modular version designed for OpenClaw skills.
- `.env`: (Ignored) Configuration for API and AI model.
