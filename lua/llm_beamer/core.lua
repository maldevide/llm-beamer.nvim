-- File: ~/.config/nvim/lua/llm_beamer/core.lua

local api = require('llm_beamer.api')
local utils = require('llm_beamer.utils')
local conversation = require('llm_beamer.conversation')
local suggestions = require('llm_beamer.suggestions')
local info = require('llm_beamer.info')

local M = {}

-- Status Window
M.current_context = ""
M.is_fetching = false
M.status_win = nil
M.status_buf = nil

function M.update_status(message, config)
    if not M.status_win or not vim.api.nvim_win_is_valid(M.status_win) then
        vim.schedule(function()
            M.status_buf = vim.api.nvim_create_buf(false, true)
            local opts = {
                relative = 'editor',
                width = #message + 2,
                height = 1,
                row = vim.o.lines - 2,
                col = vim.o.columns - #message - 4,
                style = 'minimal',
                border = 'single'
            }
            M.status_win = vim.api.nvim_open_win(M.status_buf, false, opts)
            vim.api.nvim_buf_set_lines(M.status_buf, 0, -1, false, {message})
        end)
    else
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(M.status_buf, 0, -1, false, {message})
        end)
    end
end

function M.close_status()
    if M.status_win and vim.api.nvim_win_is_valid(M.status_win) then
        vim.api.nvim_win_close(M.status_win, true)
    end
    M.status_win = nil
    M.status_buf = nil
end

function M.get_context(num_preceding_lines)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor[1]
    local current_col = cursor[2]

    local start_line = math.max(1, current_line - num_preceding_lines)
    local preceding_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, current_line, false)

    local current_line_text = vim.api.nvim_get_current_line():sub(1, current_col)

    local context = table.concat(preceding_lines, "\n") .. "\n" .. current_line_text

    return context:match("^(.-)%s*$")
end

function M.handle_activation(config)
    utils.log("Activation key pressed", config)
    
    M.current_context = M.get_context(config.num_preceding_lines)
    
    local suggestion_count = 0
    
    M.is_fetching = true
    
    local function update_suggestions(results)
        if not M.is_fetching then
            utils.log("Fetching cancelled", config)
            return
        end
        
        for _, result in ipairs(results) do
            if suggestion_count < config.num_beams then
                suggestion_count = suggestion_count + 1
                table.insert(suggestions.suggestions, result)
            else
                break
            end
        end
        
        if not suggestions.suggestion_win or not vim.api.nvim_win_is_valid(suggestions.suggestion_win) then
            if not M.is_fetching then
                utils.log("Fetching cancelled", config)
                return
            end
            suggestions.create_suggestion_window(config)
        end

        if not M.is_fetching then
            utils.log("Fetching cancelled", config)
            return
        end
        suggestions.update_suggestions(config)
        
        M.update_status(string.format("Retrieving %d/%d", suggestion_count, config.num_beams), config)
        
        if suggestion_count < config.num_beams and M.is_fetching then
            api.get_suggestions(config, M.current_context, update_suggestions)
        else
            vim.defer_fn(function()
                M.close_status()
            end, 1000)
        end
    end
    
    suggestions.suggestions = {}
    
    M.update_status("Retrieving 0/" .. config.num_beams, config)
    
    api.get_suggestions(config, M.current_context, update_suggestions) 
    return ""
end

function M.reroll_suggestions(config)
    utils.log("Rerolling suggestions", config)
    
    suggestions.suggestions = {}
    
    M.update_status("Rerolling: 0/" .. config.num_beams, config)
    
    local suggestion_count = 0
    
    M.is_fetching = true
    
    local function update_suggestions(results)
        if not M.is_fetching then
            utils.log("Fetching cancelled", config)
            return
        end
        
        for _, result in ipairs(results) do
            if suggestion_count < config.num_beams then
                suggestion_count = suggestion_count + 1
                table.insert(suggestions.suggestions, result)
            else
                break
            end
        end
        
        suggestions.update_suggestions(config)
        
        M.update_status(string.format("Rerolling %d/%d", suggestion_count, config.num_beams), config)
        
        if suggestion_count < config.num_beams then
            api.get_suggestions(config, M.current_context, update_suggestions)
        else
            vim.defer_fn(function()
                M.close_status()
            end, 1000)
        end
    end
    
    api.get_suggestions(config, M.current_context, update_suggestions)
end

-- Expose functions from other modules
M.select_suggestion = suggestions.select_suggestion
M.close_suggestion_window = suggestions.close_suggestion_window
M.create_or_focus_windows = info.create_or_focus_windows
M.close_info_windows = info.close_info_windows
M.cycle_focus = info.cycle_focus
M.get_info_buffer_content = info.get_info_buffer_content
M.set_info_buffer_content = info.set_info_buffer_content

return M
