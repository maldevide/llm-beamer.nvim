-- File: ~/.config/nvim/lua/llm_beamer/utils.lua

local M = {}

function M.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function M.starts_with_space(s)
    return s:sub(1, 1):match("%s") ~= nil
end

function M.ends_with_space(s)
    return s:sub(-1):match("%s") ~= nil
end

function M.add_space_if_needed(s1, s2)
    if not M.ends_with_space(s1) and not M.starts_with_space(s2) then
        return s1 .. " " .. s2
    else
        return s1 .. s2
    end
end

function M.encode_newlines(str)
    return str:gsub("\n", "\\n")
end

function M.decode_newlines(str)
    return str:gsub("\\n", "\n")
end

function M.log(message, config)
    if config.debug then
        vim.schedule(function()
            vim.api.nvim_echo({{message, "WarningMsg"}}, true, {})
        end)
    end
end

return M
