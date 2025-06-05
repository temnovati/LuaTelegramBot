# Telegram Bot API for Lua

A simple and lightweight Telegram Bot API wrapper for Lua. This library provides an easy way to create Telegram bots with features like buttons, commands, and message handling.

## Warning

This API was made by AI, don't hate me pls!!! :(

## Features

- Simple command handling
- Inline keyboard buttons
- Message editing and deletion
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

### Button Functions
- `api.addbutton(text, callback_data, callback)` - Add a button
- `api.removebutton(callback_data)` - Remove a button
- `api.editbutton(old_callback_data, new_text, new_callback_data, new_callback)` - Edit a button
- `api.clearbuttons()` - Clear all buttons

## Example Bot

Check out the `bot.lua` file for a complete example of a bot with:
- Multiple commands
- Different types of buttons
- Message deletion
- Message editing

## Running the Example

1. Clone the repository
2. Install dependencies
3. Edit `bot.lua` and set your bot token
4. Run the bot:
```bash
cd TBL
lua bot.lua
```


