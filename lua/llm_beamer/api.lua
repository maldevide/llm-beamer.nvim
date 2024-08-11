-- File: ~/.config/nvim/lua/llm_beamer/api.lua

local curl = require('plenary.curl')
local conversation = require('llm_beamer.conversation')

local M = {}

-- Logging functionality
local function log(message)
    vim.schedule(function()
        -- vim.api.nvim_echo({{message, "WarningMsg"}}, true, {})
    end)
end

-- Helper function to encode parameters for the API request
local function encode_params(params)
    local result = {}
    for k, v in pairs(params) do
        table.insert(result, k .. '=' .. vim.fn.encodeURIComponent(tostring(v)))
    end
    return table.concat(result, '&')
end

-- Function to safely get nested table values
local function safe_get(tbl, ...)
    local current = tbl
    for _, key in ipairs({...}) do
        if type(current) ~= "table" then return nil end
        current = current[key]
    end
    return current
end

-- Function to process the API response and extract suggestions
local function process_api_response(response, num_beams)
    log("Processing API response...")
    
    local suggestions = {}
    local choices = safe_get(response, "choices") or {}
    
    for i, choice in ipairs(choices) do
        if i > num_beams then break end
        local text = safe_get(choice, "message", "content")
        if text then
            text = text:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
            table.insert(suggestions, text)
        end
    end

    if #suggestions == 0 then
        log("No valid suggestions found in API response")
    else
        log("Processed suggestions: " .. vim.inspect(suggestions))
    end

    return suggestions
end

-- Function to make an API request
local function make_api_request(config, context, callback)
    log("Making API request...")
    
    local messages = conversation.create_conversation(config, context)

    local params = {
        model = config.model,
        messages = messages,
        max_tokens = config.max_tokens,
        n = config.num_beams,
        temperature = config.temperature,
        top_p = config.top_p,
    }

    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer ' .. config.api_key,
    }

    log("Request params: " .. vim.inspect(params))

    curl.post(config.api_url, {
        headers = headers,
        body = vim.fn.json_encode(params),
        callback = vim.schedule_wrap(function(response)
            if response.status ~= 200 then
                log("API request failed with status " .. response.status .. ": " .. response.body)
                callback({})
                return
            end

            log("API response received. Status: " .. response.status)
            local ok, decoded_response = pcall(vim.fn.json_decode, response.body)
            if not ok then
                log("Failed to decode API response: " .. tostring(decoded_response))
                callback({})
                return
            end
            
            local suggestions = process_api_response(decoded_response, config.num_beams)
            callback(suggestions)
        end)
    })
end

-- Main function to get suggestions from the API
function M.get_suggestions(config, context, callback)
    log("Getting suggestions for context: " .. context)

    make_api_request(config, context, callback)
end

return M
