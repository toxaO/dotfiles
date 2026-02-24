local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local M = {}

function M.get_vim_lines()
  return api.nvim_eval("&lines")
end

function M.get_vim_columns()
  return api.nvim_eval("&columns")
end

function M.win_all()
  return fn.range(1, fn.winnr("$"))
end

function M.win_count()
  return fn.winnr("$")
end

return M

