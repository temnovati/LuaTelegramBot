# Telegram Bot API for Lua

A simple and lightweight Telegram Bot API wrapper for Lua. This library provides an easy way to create Telegram bots with features like buttons, commands, and message handling.

## Features

- Simple command handling
- Inline keyboard buttons with URL support
- Message editing and deletion
- File sending (photos, videos, audio, documents, archives, etc.)
- Chat history tracking
- User tracking
- Popup notifications
- Easy to use API

## Installation

1. Install required dependencies:
```bash
luarocks install luasocket
luarocks install dkjson
luarocks install lua-cjson
```

2. Copy the `telegramapi.lua` file to your project.

## Example

```lua
local api = require('telegramapi')

-- Set bot token
api.token = "YOUR_TOKEN"

-- Start command
api.createcommand("start", function(message)
    api.addbutton("Be sigma", "button1", nil, "https://ru.pinterest.com/pin/940407965937376362/")

    api.send_message(message.chat.id, "menu")
end)

-- Run bot
api.run()

-- Run bot
api.run()
```

## Available Functions

### Basic Functions
- `api.createcommand(name, callback)` - Create a new command
- `api.send_message(chat_id, text)` - Send a message
- `api.editmessage(chat_id, message_id, new_text)` - Edit a message
- `api.removemessage(chat_id, message_id)` - Delete a message
- `api.send_file(chat_id, file_path, caption)` - Send any type of file
- `api.show_popup(callback_query_id, text, show_alert)` - Show popup notification

### Button Functions
- `api.addbutton(text, callback_data, callback, url)` - Add a button
  - `text` - Button text
  - `callback_data` - Unique identifier (nil if using URL)
  - `callback` - Function to call when pressed (nil if using URL)
  - `url` - URL to open when pressed (optional)
- `api.removebutton(callback_data)` - Remove a button
- `api.editbutton(old_callback_data, new_text, new_callback_data, new_callback)` - Edit a button
- `api.clearbuttons()` - Clear all buttons

### Chat Data Functions
- `api.getdatafromchat(chat_id)` - Get all chat data including:
  - `allmessages` - Table of all messages with message_id as key
  - `allusers` - Table of all users with user_id as key

## Example Bot

Check out the `bot.lua` file for a complete example of a bot with:
- Multiple commands
- Different types of buttons (URL and callback)
- Popup notifications
- Message editing
- File sending
- Chat history tracking
- User tracking

## Running the Example

1. Clone the repository
2. Install dependencies
3. Edit `bot.lua` and set your bot token
4. Run the bot:
```bash
cd TBL
lua bot.lua
```

> [!IMPORTANT]
> My discord: seniorsword

> [!WARNING]
> This API was made by AI, don't hate me pls!!! 😅
> 
