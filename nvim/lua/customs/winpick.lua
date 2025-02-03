local g = vim.g
local fn = vim.fn
local uv = vim.uv
local api = vim.api
local opt = vim.opt
local cmd = vim.cmd
local keymap = vim.keymap

local u = require("utils")

local M = {}

M.winpick = require("winpick")

-- choose window for window focus
function M.choose_for_focus()
  local winid = M.winpick.select()
  if winid then
    api.nvim_set_current_win(winid)
  end
end

-- for file open
function M.choose_for_open(path)
  local name = u.path.path2name(path)
  local winid = M.winpick.select({prompt = "Select window for [" .. name .. "]"})
  if winid then
    api.nvim_set_current_win(winid)
    cmd("edit " .. path)
    else
    cmd("badd" .. path)
  end
end

-- choose window for window move
function M.choose_for_move()
  --local current_bufnr = fn["bufnr"]('%')
  --local current_winid = fn["wingetid"]()
  local current_winid, current_bufnr = M.winpick.select({prompt = "Move from?", border = "single"})
  if current_winid then
    local target_winid, target_bufnr = M.winpick.select({prompt = "Move to?", border = "double"})
    if target_winid then
      --vim.api.nvim_set_current_win(winid)
      api.nvim_win_set_buf(current_winid, target_bufnr)
      api.nvim_win_set_buf(target_winid, current_bufnr)
    end
  end
end

return M
