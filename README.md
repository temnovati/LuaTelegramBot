# Telegram Bot API for Lua

A simple and lightweight Telegram Bot API wrapper for Lua. This library provides an easy way to create Telegram bots with features like buttons, commands, and message handling.

## Warning

This API was made by AI, don't hate me pls!!! :(

## Features

- Simple command handling
- Inline keyboard buttons
- Message editing and deletion
- File sending (photos, videos, audio, documents, etc.)
- Easy to use API

## Installation

1. Install required dependencies:
```bash
luarocks install luasocket
luarocks install dkjson
luarocks install lua-cjson
```

2. Copy the `telegramapi.lua` file to your project.

## Quick Start

```lua
local api = require('telegramapi')

-- Set your bot token
api.token = 'YOUR_BOT_TOKEN'

-- Create a command
api.createcommand("start", function(message)
    api.send_message(message.chat.id, "Hello! I'm your bot!")
end)

-- Send a file
api.createcommand("file", function(message)
    api.send_file(
        message.chat.id,
        "path/to/your/file.jpg",
        "This is a caption for the file"
    )
end)

-- Add a button
api.addbutton("Click me", "click", function(callback)
    api.removemessage(
        callback.message.chat.id,
        callback.message.message_id
    )
end)

-- Run the bot
api.run()
```

## Available Functions

### Basic Functions
- `api.createcommand(name, callback)` - Create a new command
- `api.send_message(chat_id, text)` - Send a message
- `api.editmessage(chat_id, message_id, new_text)` - Edit a message
- `api.removemessage(chat_id, message_id)` - Delete a message
- `api.send_file(chat_id, file_path, caption)` - Send any type of file

### Button Functions
- `api.addbutton(text, callback_data, callback)` - Add a button
- `api.removebutton(callback_data)` - Remove a button
- `api.editbutton(old_callback_data, new_text, new_callback_data, new_callback)` - Edit a button
- `api.clearbuttons()` - Clear all buttons

## Supported File Types

The `send_file` function automatically detects file type and uses appropriate Telegram API method:

- Photos: jpg, jpeg, png
- Videos: mp4, mov
- Audio: mp3, ogg, wav
- Animations: gif
- Documents: all other file types

## Example Bot

Check out the `bot.lua` file for a complete example of a bot with:
- Multiple commands
- Different types of buttons
- Message deletion
- Message editing
- File sending

## Running the Example

1. Clone the repository
2. Install dependencies
3. Edit `bot.lua` and set your bot token
4. Run the bot:
```bash
cd TBL
lua bot.lua
```
