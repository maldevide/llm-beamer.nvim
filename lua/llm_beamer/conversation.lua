-- File: ~/.config/nvim/lua/llm_beamer/conversation.lua

local M = {}

-- Function to split a string into two parts at a specific line
local function split_at_line(str, line_number)
    local lines = vim.split(str, "\n")
    
    -- If we have fewer lines than the split point, return empty first part
    if #lines < line_number then
        return "", table.concat(lines, "\n")
    end
    
    local first_part = table.concat(lines, "\n", 1, line_number)
    local second_part = table.concat(lines, "\n", line_number + 1)
    
    return first_part, second_part
end

-- Function to create a structured conversation
function M.create_conversation(config, context)
    local messages = {}

    -- Get additional info from the info buffer
    local user_request = ""
    if config.user_request_buf and vim.api.nvim_buf_is_valid(config.user_request_buf) then
        local info_lines = vim.api.nvim_buf_get_lines(config.user_request_buf, 0, -1, false)
        user_request = table.concat(info_lines, "\n")
    end

    local additional_info = ""
    if config.info_buf and vim.api.nvim_buf_is_valid(config.info_buf) then
        local info_lines = vim.api.nvim_buf_get_lines(config.info_buf, 0, -1, false)
        additional_info = table.concat(info_lines, "\n")
    end
    
    local continuation = ""
    if config.continuation_buf and vim.api.nvim_buf_is_valid(config.continuation_buf) then
        local info_lines = vim.api.nvim_buf_get_lines(config.continuation_buf, 0, -1, false)
        continuation = table.concat(info_lines, "\n")
    end
    
    -- Add system message
    table.insert(messages, {role = "system", content = config.system_prompt})
    
    -- Initial user turn
    if user_request and user_request ~= "" then 
        table.insert(messages, {role = "user", content = user_request})
    else
        table.insert(messages, {role = "user", content = "Continue"})
    end
    
    -- Split context at the specified fold line
    local first_part, second_part = split_at_line(context, config.fold_at)
    
    -- Assistant outputs first part of context
    table.insert(messages, {role = "assistant", content = first_part})
    
    -- User provides additional info
    if additional_info and additional_info ~= "" then
        table.insert(messages, {role = "user", content = additional_info})
    else
        table.insert(messages, {role = "user", content = "Continue"})
    end
    
    -- Assistant outputs second part of context
    table.insert(messages, {role = "assistant", content = second_part})
    
    -- Final user turn
    if continuation and continuation ~= "" then
        table.insert(messages, {role = "user", content = continuation})
    else
        table.insert(messages, {role = "user", content = "Continue"})
    end
    
    return messages
end

return M
