local http = require("socket.http")
local json = require("dkjson")
local ltn12 = require("ltn12")

--[[
Installation:
luarocks install luasocket
luarocks install dkjson
luarocks install lua-cjson

Usage:
local api = require('telegramapi')
api.token = 'YOUR_BOT_TOKEN' -- Set your token here
--]]

local api = {
    token = nil, -- Token needs to be set before use
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
function api.addbutton(text, callback_data, callback, url)
    local button = {
        text = text
    }
    
    if url then
        button.url = url
    else
        button.callback_data = callback_data
        api.callbacks[callback_data] = callback
    end
    
    if not api.buttons then api.buttons = {} end
    table.insert(api.buttons, button)
    print("Button created: " .. text .. (url and " with URL" or ""))
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

-- Send message with buttons
function api.send_message(chat_id, text)
    local params = {
        chat_id = chat_id,
        text = text
    }
    
    if api.buttons and #api.buttons > 0 then
        params.reply_markup = {
            inline_keyboard = {api.buttons}
        }
        api.buttons = {} -- Clear buttons after sending
    end
    
    return api.request("sendMessage", params)
end

-- Edit message with buttons
function api.editmessage(chat_id, message_id, new_text)
    local params = {
        chat_id = chat_id,
        message_id = message_id,
        text = new_text
    }
    
    if api.buttons and #api.buttons > 0 then
        params.reply_markup = {
            inline_keyboard = {api.buttons}
        }
        api.buttons = {} -- Clear buttons after sending
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
    -- Process all messages, not just commands
    if message.text then
        local command = message.text:match('^/(%w+)')
        if command and api.commands[command] then
            api.commands[command](message)
        end
    end
    
    -- Add message to history
    if not api.message_history then
        api.message_history = {}
    end
    
    if message.chat then
        if not api.message_history[message.chat.id] then
            api.message_history[message.chat.id] = {}
        end
        
        api.message_history[message.chat.id][message.message_id] = {
            text = message.text,
            date = message.date,
            from = message.from
        }
    end
end

-- Handle callback queries
function api.on_callback_query(callback_query)
    if callback_query.data and api.callbacks[callback_query.data] then
        api.callbacks[callback_query.data](callback_query)
    end
end

-- Remove message
function api.removemessage(chat_id, message_id)
    local params = {
        chat_id = chat_id,
        message_id = message_id
    }
    
    return api.request("deleteMessage", params)
end

-- Send file (universal function for all file types)
function api.send_file(chat_id, file_path, caption)
    local params = {
        chat_id = chat_id
    }
    
    -- Determine file type by extension
    local file_type = file_path:match("%.([^%.]+)$"):lower()
    
    -- Choose API method based on file type
    local method = "sendDocument" -- default as document
    
    if file_type == "jpg" or file_type == "jpeg" or file_type == "png" then
        method = "sendPhoto"
    elseif file_type == "mp4" or file_type == "mov" then
        method = "sendVideo"
    elseif file_type == "mp3" or file_type == "ogg" or file_type == "wav" then
        method = "sendAudio"
    elseif file_type == "gif" then
        method = "sendAnimation"
    elseif file_type == "zip" or file_type == "rar" then
        method = "sendDocument"
        -- Add file type to caption for archives
        if caption then
            caption = caption .. " (Archive: " .. file_type:upper() .. ")"
        else
            caption = "Archive: " .. file_type:upper()
        end
    end
    
    -- Add caption if provided
    if caption then
        params.caption = caption
    end
    
    -- Open file
    local file = io.open(file_path, "rb")
    if not file then
        return nil, "File not found"
    end
    
    -- Read file content
    local content = file:read("*all")
    file:close()
    
    -- Create multipart/form-data request
    local boundary = "----WebKitFormBoundary" .. os.time()
    local body = ""
    
    -- Add parameters
    for k, v in pairs(params) do
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"" .. k .. "\"\r\n\r\n"
        body = body .. v .. "\r\n"
    end
    
    -- Add file
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"" .. method:match("send(%w+)"):lower() .. "\"; filename=\"" .. file_path:match("([^/\\]+)$") .. "\"\r\n"
    body = body .. "Content-Type: " .. (method == "sendPhoto" and "image/jpeg" or "application/octet-stream") .. "\r\n\r\n"
    body = body .. content .. "\r\n"
    body = body .. "--" .. boundary .. "--\r\n"
    
    -- Send request
    local url = api.base_url .. api.token .. "/" .. method
    local response = {}
    
    local res, code = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
            ["Content-Length"] = #body
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response)
    }
    
    if code == 200 then
        return json.decode(table.concat(response))
    end
    return nil, "Failed to send file"
end

-- Show popup notification
function api.show_popup(callback_query_id, text, show_alert)
    local params = {
        callback_query_id = callback_query_id,
        text = text,
        show_alert = show_alert == nil and true or show_alert
    }
    return api.request("answerCallbackQuery", params)
end

-- Get all data from chat (messages and users)
function api.getdatafromchat(chat_id)
    local result = {
        allmessages = {},
        allusers = {}
    }
    
    -- Create table for tracking unique users
    local unique_users = {}
    
    -- Use saved message history
    if api.message_history and api.message_history[chat_id] then
        for message_id, msg in pairs(api.message_history[chat_id]) do
            result.allmessages[message_id] = msg
            
            -- Add user if not exists
            if msg.from then
                local user_id = msg.from.id
                if not unique_users[user_id] then
                    unique_users[user_id] = true
                    result.allusers[user_id] = {
                        first_name = msg.from.first_name,
                        last_name = msg.from.last_name,
                        username = msg.from.username
                    }
                end
            end
        end
    end
    
    return result
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
