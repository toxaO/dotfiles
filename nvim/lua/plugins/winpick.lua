local g = vim.g
local fn = vim.fn
local uv = vim.uv
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local function ignore_winsep(winid, bufnr, _)
  if fn["getwininfo"](winid)[1]["height"] == 1
  or fn["getwininfo"](winid)[1]["width"] == 1 then
    return false
  else
    return true
  end
end

return{
  {
    "gbrlsnchs/winpick.nvim",
    config = function()

      local winpick = require("winpick")
      winpick.setup({
        border = "double",
        filter = ignore_winsep,
        prompt = "Pick a window: ",
        format_label = winpick.defaults.format_label,
        chars = {"a", "s", "d", "f", "g", "h", "j", "k", "l", ";"},
      })

      local myWinPick = require("customs.winpick")

      -- api.nvim_create_user_command("WinPick", myWinPick.choose_for_focus, {})
      vim.keymap.set("n", "<Space>w", myWinPick.choose_for_focus)
      --api.nvim_create_user_command("WinExchange", myWinPick.choose_for_move {})
      vim.keymap.set("n", "<Space>m", myWinPick.choose_for_move)

    end,
  },
}
