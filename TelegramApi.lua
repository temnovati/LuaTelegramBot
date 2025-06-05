local http = require("socket.http")
local json = require("dkjson")
local ltn12 = require("ltn12")

-- install: local api = require('telegramapi')

local api = {
    token = '8135074733:AAGMAvoNEdB-G8ggmRVrYKsvuzWIw7-uNe8',
    commands = {},
    callbacks = {},
    buttons = {},
    base_url = "https://api.telegram.org/bot"
}

-- Create command
function api.createcommand(name, callback)
    api.commands[name] = callback
    print("Command created: " .. name)
end

-- Add button
function api.addbutton(text, callback_data, callback)
    table.insert(api.buttons, {
        text = text,
        callback_data = callback_data
    })
    api.callbacks[callback_data] = callback
    print("Button created: " .. text)
end

-- Remove button by callback_data
function api.removebutton(callback_data)
    for i, button in ipairs(api.buttons) do
        if button.callback_data == callback_data then
            table.remove(api.buttons, i)
            api.callbacks[callback_data] = nil
            print("Button removed: " .. button.text)
            break
        end
    end
end

-- Edit button
function api.editbutton(old_callback_data, new_text, new_callback_data, new_callback)
    for i, button in ipairs(api.buttons) do
        if button.callback_data == old_callback_data then
            api.buttons[i].text = new_text
            api.buttons[i].callback_data = new_callback_data
            api.callbacks[old_callback_data] = nil
            api.callbacks[new_callback_data] = new_callback
            print("Button edited: " .. new_text)
            break
        end
    end
end

-- Clear all buttons
function api.clearbuttons()
    api.buttons = {}
    api.callbacks = {}
    print("All buttons cleared")
end

-- Create keyboard
function api.create_keyboard()
    local keyboard = {
        inline_keyboard = {}
    }
    
    -- Add all buttons in one row
    local row = {}
    for _, button in ipairs(api.buttons) do
        table.insert(row, {
            text = button.text,
            callback_data = button.callback_data
        })
    end
    table.insert(keyboard.inline_keyboard, row)
    
    return json.encode(keyboard)
end

-- Send HTTP request
function api.request(method, params)
    local url = api.base_url .. api.token .. "/" .. method
    local response = {}
    
    local body = json.encode(params or {})
    
    local res, code = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #body
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    }
    
    if code == 200 then
        return json.decode(table.concat(response))
    end
    return nil
end

-- Send message
function api.send_message(chat_id, text)
    local params = {
        chat_id = chat_id,
        text = text
    }
    
    -- Add keyboard if there are buttons
    if #api.buttons > 0 then
        params.reply_markup = api.create_keyboard()
    end
    
    return api.request("sendMessage", params)
end

-- Edit message
function api.editmessage(chat_id, message_id, new_text)
    local params = {
        chat_id = chat_id,
        message_id = message_id,
        text = new_text
    }
    
    -- Add keyboard if there are buttons
    if #api.buttons > 0 then
        params.reply_markup = api.create_keyboard()
    end
    
    return api.request("editMessageText", params)
end

-- Get updates
function api.get_updates(offset)
    local params = {
        timeout = 30
    }
    if offset then
        params.offset = offset
    end
    
    return api.request("getUpdates", params)
end

-- Handle messages
function api.on_message(message)
    if message.text then
        local command = message.text:match('^/(%w+)')
        if command and api.commands[command] then
            api.commands[command](message)
        end
    end
end

-- Handle callback queries
function api.on_callback_query(callback_query)
    if callback_query.data and api.callbacks[callback_query.data] then
        api.callbacks[callback_query.data](callback_query)
    end
end

-- Add button with effect
function api.addbutton_with_effect(text, callback_data, callback)
    -- Add button
    api.addbutton(text, callback_data, function(callback_query)
        -- Call main callback
        callback(callback_query)
        
        -- Remove button
        api.removebutton(callback_data)
        
        -- Add button again
        api.addbutton(text, callback_data, function(callback_query)
            callback(callback_query)
            api.removebutton(callback_data)
            api.addbutton(text, callback_data, function(callback_query)
                callback(callback_query)
            end)
        end)
    end)
end

-- Run bot
function api.run()
    print("Bot started with token: " .. api.token)
    local offset = 0
    
    while true do
        local updates = api.get_updates(offset)
        if updates and updates.ok then
            for _, update in ipairs(updates.result) do
                offset = update.update_id + 1
                
                if update.message then
                    api.on_message(update.message)
                elseif update.callback_query then
                    api.on_callback_query(update.callback_query)
                end
            end
        end
    end
end

return api
