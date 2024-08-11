-- File: ~/.config/nvim/lua/llm_beamer/init.lua

local utils = require('llm_beamer.utils')
local core = require('llm_beamer.core')
local help = require('llm_beamer.help')
local info = require('llm_beamer.info')

local M = {}

-- Configuration options
M.config = {
    api_url = "http://10.100.0.57:5001/v1/chat/completions",
    api_key = "",
    model = "llama3",
    num_words = 5,
    num_beams = 4,
    num_preceding_lines = 10,
    context_window_width = 200,
    max_tokens = 48,
    system_prompt = "Continue the story from where the user leaves off; continue the story, adding new content.",
    debounce_ms = 100,
    temperature = 0.85,
    top_p = 1,
    status_update_interval_ms = 100,
    fold_at = 5,
    debug = true,
}

-- Expose core functions
M.select_suggestion = function()
    core.select_suggestion(M.config)
end

M.close_suggestion_window = core.close_suggestion_window
M.create_or_focus_windows = function()
    core.create_or_focus_windows(M.config)
end
M.close_info_windows = core.close_info_windows
M.cycle_focus = core.cycle_focus

M.handle_activation = function()
    return core.handle_activation(M.config)
end

M.reroll_suggestions = function()
    core.reroll_suggestions(M.config)
end

M.show_help = function()
    help.show_help(M.config, core)
end

-- Expose new functions
M.save_buffers = info.save_buffers
M.load_buffers = info.load_buffers

function M.set_model(model_name)
    M.config.model = model_name
    print("LLM Beamer model set to: " .. model_name)
end

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
    
    vim.api.nvim_set_keymap('i', '<S-Tab>', [[<Cmd>lua require('llm_beamer').handle_activation()<CR>]], {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '<leader>bi', [[<Cmd>lua require('llm_beamer').create_or_focus_windows()<CR>]], {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '<leader>bh', [[<Cmd>lua require('llm_beamer').show_help()<CR>]], {noremap = true, silent = true})
    
    -- Add new key mappings for save and load
    vim.api.nvim_set_keymap('n', '<leader>bs', [[<Cmd>lua require('llm_beamer').save_buffers()<CR>]], {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', '<leader>bl', [[<Cmd>lua require('llm_beamer').load_buffers()<CR>]], {noremap = true, silent = true})
    
    -- Add new commands
    vim.api.nvim_create_user_command('LLMBeamerSave', M.save_buffers, {})
    vim.api.nvim_create_user_command('LLMBeamerLoad', M.load_buffers, {})
    
    -- Load buffers on startup
    vim.defer_fn(M.load_buffers, 0)
    
    utils.log("LLM Beamer plugin initialized", M.config)
end

return M
