local g = vim.g
local fn = vim.fn
local uv = vim.uv
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local M = {}

-- ignore colorful_winsep
local function ignore_winsep(winid, bufnr, _)
  if fn["getwininfo"](winid)[1]["height"] == 1
  or fn["getwininfo"](winid)[1]["width"] == 1 then
    return false
  else
    return true
  end
end

function M.setup()
  M.winpick = require("winpick")
  M.winpick.setup({
    border = "double",
    filter = ignore_winsep,
    prompt = "Pick a window: ",
    format_label = M.winpick.defaults.format_label,
    chars = {"a", "s", "d", "f", "g", "h", "j", "k", "l", ";"},
  })
end

-- choose window for window focus
--
function M.choose_for_focus()
  local winid = M.winpick.select()
  if winid then
    vim.api.nvim_set_current_win(winid)
  end
end

--
-- choose window for window move
--
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
