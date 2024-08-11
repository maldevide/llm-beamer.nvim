-- File: ~/.config/nvim/lua/llm_beamer/suggestions.lua

local M = {}

-- Window and buffer for displaying suggestions
M.suggestion_win = nil
M.suggestion_buf = nil

-- Array to store current suggestions
M.suggestions = {}

-- Function to update the suggestions in the suggestion window
function M.update_suggestions(config)
    if M.suggestion_buf and vim.api.nvim_buf_is_valid(M.suggestion_buf) then
        vim.schedule(function()
            vim.api.nvim_buf_set_option(M.suggestion_buf, 'modifiable', true)
            -- Encode newlines to prevent multi-line suggestions from breaking the display
            local encoded_suggestions = vim.tbl_map(function(s) return s:gsub("\n", "\\n") end, M.suggestions)
            vim.api.nvim_buf_set_lines(M.suggestion_buf, 0, -1, false, encoded_suggestions)
            vim.api.nvim_buf_set_option(M.suggestion_buf, 'modifiable', false)
        end)
    end
end

-- Function to close the suggestion window
function M.close_suggestion_window()
    -- Stop fetching suggestions and close the status window
    require('llm_beamer.core').is_fetching = false
    require('llm_beamer.core').close_status()
    
    -- Close the suggestion window if it exists and is valid
    if M.suggestion_win and vim.api.nvim_win_is_valid(M.suggestion_win) then
        vim.api.nvim_win_close(M.suggestion_win, true)
    end
    
    -- Reset window and buffer references
    M.suggestion_win = nil
    M.suggestion_buf = nil
    vim.schedule(function()
        vim.cmd('startinsert!')
    end)
end

-- Function to create the suggestion window
function M.create_suggestion_window(config)
    -- Create a new buffer for suggestions
    M.suggestion_buf = vim.api.nvim_create_buf(false, true)
    
    local width = config.context_window_width
    local height = config.num_beams

    local opts = {
        relative = 'cursor',
        width = width,
        height = height,
        row = 1,
        col = 0,
        style = 'minimal',
        border = 'single',
        title = 'Suggestions <enter to select, r to reroll, esc to exit>',
        title_pos = 'center'
    }

    vim.schedule(function()
        M.suggestion_win = vim.api.nvim_open_win(M.suggestion_buf, true, opts)

        vim.schedule(function()
            vim.cmd('stopinsert!')
        end)

        vim.api.nvim_buf_set_option(M.suggestion_buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(M.suggestion_buf, 'buftype', 'nofile')
        vim.api.nvim_win_set_option(M.suggestion_win, 'cursorline', true)

        vim.api.nvim_buf_set_keymap(M.suggestion_buf, 'n', '<CR>', '<cmd>lua require("llm_beamer").select_suggestion()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.suggestion_buf, 'n', '<Esc>', '<cmd>lua require("llm_beamer").close_suggestion_window()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(M.suggestion_buf, 'n', 'r', '<cmd>lua require("llm_beamer").reroll_suggestions()<CR>', { noremap = true, silent = true })
    
    end)
end

-- Function to select and insert a suggestion
function M.select_suggestion(config)
    if M.suggestion_win and vim.api.nvim_win_is_valid(M.suggestion_win) then
        local cursor = vim.api.nvim_win_get_cursor(M.suggestion_win)
        local row = cursor[1]
        local selected_line = vim.api.nvim_buf_get_lines(M.suggestion_buf, row - 1, row, false)[1]
        
        -- Store the main window handle
        local main_win = vim.fn.win_getid(vim.fn.winnr('#'))
        
        -- Close the suggestion window and stop fetching
        require('llm_beamer.core').is_fetching = false
        
        -- Ensure we're in the main window and in normal mode
        vim.api.nvim_set_current_win(main_win)
        vim.cmd('stopinsert')
        
        vim.schedule(function()
            local decoded_line = selected_line:gsub("\\n", "\n")
            local lines_to_insert = vim.split(decoded_line, '\n')
            local current_pos = vim.api.nvim_win_get_cursor(0)
            local current_line = vim.api.nvim_get_current_line()
            
            -- This offset we use is important, don't remove it
            local line_before = current_line:sub(1, current_pos[2] + 1)
            local line_after = current_line:sub(current_pos[2] + 2)
            
            local need_space = #line_before > 0 and not line_before:match("%s$") and not lines_to_insert[1]:match("^%s")
            
            local new_lines = {}
            if #line_before > 0 then
                new_lines[1] = need_space and (line_before .. " " .. lines_to_insert[1]) or (line_before .. lines_to_insert[1])
            else
                new_lines[1] = lines_to_insert[1]
            end
            for i = 2, #lines_to_insert do
                table.insert(new_lines, lines_to_insert[i])
            end
            new_lines[#new_lines] = new_lines[#new_lines] .. line_after
            
            vim.api.nvim_buf_set_lines(0, current_pos[1] - 1, current_pos[1], false, new_lines)
            
            local new_col = #new_lines[#new_lines] - #line_after
            vim.api.nvim_win_set_cursor(0, {current_pos[1] + #new_lines - 1, new_col})
            
            vim.cmd('startinsert!')
        end)

        M.close_suggestion_window()
    end
end

return M
