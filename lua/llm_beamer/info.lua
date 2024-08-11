-- File: ~/.config/nvim/lua/llm_beamer/info.lua

local M = {}

M.info_buffers = {
    { name = 'user_request', buf = nil, win = nil },
    { name = 'info', buf = nil, win = nil },
    { name = 'continuation_request', buf = nil, win = nil }
}

function M.get_info_buffer_content(buf_name)
    for _, buf_info in ipairs(M.info_buffers) do
        if buf_info.name == buf_name and buf_info.buf and vim.api.nvim_buf_is_valid(buf_info.buf) then
            return table.concat(vim.api.nvim_buf_get_lines(buf_info.buf, 0, -1, false), "\n")
        end
    end
    return ""
end

function M.set_info_buffer_content(buf_name, content)
    for _, buf_info in ipairs(M.info_buffers) do
        if buf_info.name == buf_name then
            if not buf_info.buf or not vim.api.nvim_buf_is_valid(buf_info.buf) then
                buf_info.buf = vim.api.nvim_create_buf(false, true)
                print("LLM Beamer: Created new buffer for " .. buf_name)
            end
            vim.api.nvim_buf_set_lines(buf_info.buf, 0, -1, false, vim.split(content, "\n"))
            print("LLM Beamer: Set content for " .. buf_name)
            break
        end
    end
end

-- Serialize buffer contents
function M.serialize_buffers()
    local serialized = {}
    for _, buf_info in ipairs(M.info_buffers) do
        if buf_info.buf and vim.api.nvim_buf_is_valid(buf_info.buf) then
            serialized[buf_info.name] = table.concat(vim.api.nvim_buf_get_lines(buf_info.buf, 0, -1, false), "\n")
        end
    end
    return vim.fn.json_encode(serialized)
end

-- Deserialize and load buffer contents
function M.deserialize_buffers(serialized)
    local buffers = vim.fn.json_decode(serialized)
    for _, buf_info in ipairs(M.info_buffers) do
        if buffers[buf_info.name] then
            M.set_info_buffer_content(buf_info.name, buffers[buf_info.name])
        end
    end
end

-- Save buffer contents to ShaDa
function M.save_buffers()
    local serialized = M.serialize_buffers()
    vim.fn.setreg('lbm', serialized, 'b')  -- 'b' for binary mode
    vim.cmd('wshada!')
    print("LLM Beamer: Buffers saved")
end

-- Load buffer contents from ShaDa
function M.load_buffers()
    vim.cmd('rshada!')
    vim.schedule(function()
        local serialized = vim.fn.getreg('lbm', 1, true)[1]
        if serialized then
            M.deserialize_buffers(serialized)
            print("LLM Beamer: Buffers loaded")
        else
            print("LLM Beamer: No saved buffers found")
        end
    end)
end

function M.create_or_focus_windows(config)
    if M.info_buffers[1].win and vim.api.nvim_win_is_valid(M.info_buffers[1].win) then
        M.close_info_windows()
        return
    end

    local width = vim.o.columns

    for i, buf_info in ipairs(M.info_buffers) do
        buf_info.buf = buf_info.buf or vim.api.nvim_create_buf(false, true)
        
        local title
        if i == 1 then
            title = buf_info.name:gsub("_", " "):gsub("^%l", string.upper) .. " <esc to exit, tab to cycle>"
        else
            title = buf_info.name:gsub("_", " "):gsub("^%l", string.upper)
        end
        
        buf_info.win = vim.api.nvim_open_win(buf_info.buf, i == 1, {
            relative = 'editor',
            width = width,
            height = 8,
            row = (i - 1) * (8 + 2),
            col = 0,
            style = 'minimal',
            border = 'single',
            title = title,
            title_pos = 'center'
        })

        vim.api.nvim_buf_set_option(buf_info.buf, 'modifiable', true)
        vim.api.nvim_buf_set_option(buf_info.buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf_info.buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(buf_info.buf, 'bufhidden', 'hide')

        vim.api.nvim_buf_set_keymap(buf_info.buf, 'n', '<Tab>', '<cmd>lua require("llm_beamer").cycle_focus()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf_info.buf, 'i', '<Tab>', '<Esc><cmd>lua require("llm_beamer").cycle_focus()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf_info.buf, 'n', '<Esc>', '<cmd>lua require("llm_beamer").close_info_windows()<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf_info.buf, 'i', '<Esc>', '<Esc><cmd>lua require("llm_beamer").close_info_windows()<CR>', { noremap = true, silent = true })
    end

    vim.api.nvim_set_current_win(M.info_buffers[1].win)
    vim.cmd('startinsert')
end

function M.close_info_windows()
    for _, buf_info in ipairs(M.info_buffers) do
        if buf_info.win and vim.api.nvim_win_is_valid(buf_info.win) then
            vim.api.nvim_win_close(buf_info.win, true)
        end
        buf_info.win = nil
    end
end

function M.cycle_focus()
    local valid_windows = {}
    for _, buf_info in ipairs(M.info_buffers) do
        if buf_info.win and vim.api.nvim_win_is_valid(buf_info.win) then
            table.insert(valid_windows, buf_info.win)
        end
    end

    if #valid_windows == 0 then
        print("No valid windows to cycle through")
        return
    end

    local current_win = vim.api.nvim_get_current_win()
    local current_index = 0
    for i, win in ipairs(valid_windows) do
        if win == current_win then
            current_index = i
            break
        end
    end

    local next_index = (current_index % #valid_windows) + 1
    vim.api.nvim_set_current_win(valid_windows[next_index])
end

return M
