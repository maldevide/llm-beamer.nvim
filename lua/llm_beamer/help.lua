-- File: ~/.config/nvim/lua/llm_beamer/help.lua

local M = {}

-- Function to generate the help content
local function generate_help_content(config, core)
    local help_text = [[
LLM Beamer Help
===============

LLM Beamer is a Neovim plugin that provides AI-powered text completion.

Keybindings:
- <S-Tab> in insert mode: Activate LLM Beamer
- <leader>bi in normal mode: Open info windows
- <Enter> in suggestion window: Select suggestion
- r in suggestion window: Reroll suggestions
- <Esc> in any LLM Beamer window: Close window
- <leader>bh in normal mode: Show this help window

Current Configuration:
]]

    -- Add configuration details
    if config then
        for key, value in pairs(config) do
            if type(value) ~= "function" then
                help_text = help_text .. string.format("- %s: %s\n", key, tostring(value))
            end
        end
    else
        help_text = help_text .. "Configuration not available.\n"
    end

    -- Add info buffer contents
    help_text = help_text .. "\nInfo Buffer Contents:\n"
    if core and core.get_info_buffer_content then
        local info_buffers = {'info', 'user_request', 'continuation_request'}
        for _, buf_name in ipairs(info_buffers) do
            local content = core.get_info_buffer_content(buf_name)
            help_text = help_text .. string.format("\n%s:\n%s\n", buf_name:gsub("_", " "):gsub("^%l", string.upper), content)
        end
    else
        help_text = help_text .. "Info buffer content not available.\n"
    end

    return help_text
end

-- Function to create and show the help window
function M.show_help(config, core)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' LLM Beamer Help ',
        title_pos = 'center'
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    -- Generate and set content
    local content = generate_help_content(config, core)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))

    -- Set buffer to read-only
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Set keymaps
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', {noremap = true, silent = true})

    -- Set filetype for syntax highlighting
    vim.api.nvim_buf_set_option(buf, 'filetype', 'help')
end

return M
