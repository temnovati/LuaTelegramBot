# Telegram Bot API for Lua

A simple and lightweight Telegram Bot API wrapper for Lua. This library provides an easy way to create Telegram bots with features like buttons, commands, and message handling.

## Features

- Simple command handling
- Inline keyboard buttons
- Message editing and deletion
- File sending (photos, videos, audio, documents, archives, etc.)
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

-- Example usage
api.createcommand("start", function(message)
    -- First add button
    api.clearbuttons() -- Clear old buttons
    api.addbutton("'sus button'", "button1", function(callback)
        
        api.removebutton("button1")

        api.editmessage(
            callback.message.chat.id,
            callback.message.message_id,
            "i know your name."
        )

        os.execute("sleep " .. tostring(1))

        api.editmessage(
            callback.message.chat.id,
            callback.message.message_id,
            callback.from.first_name..". Right?"
        )
    end)

    -- Then send message with button
    api.send_message(
        message.chat.id,
        "Hello i'm cool bot!!! press this button"
    )
end)

-- Run bot
api.run()
```

## Available Functions

### Basic Functions
- `api.createcommand(name, callback)` - Create a new command
- `api.send_message(chat_id, text)` - Send a message
- `api.editmessage(chat_id, message_id, new_text)` - Edit a message
- `api.removemessage(chat_id, message_id)` - Delete a message
- `api.send_file(chat_id, file_path, caption)` - Send any type of file (photos, videos, audio, documents, archives)

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
- File sending

## Running the Example

1. Clone the repository
2. Install dependencies
3. Edit `bot.lua` and set your bot token
4. Run the bot:
```bash
cd "folder_name"
lua "file_name".lua
```

> [!WARNING]
> This API was made by AI, don't hate me pls!!! 😅


## Contributing

Feel free to submit issues and pull requests! 
