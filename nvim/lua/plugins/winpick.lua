local g = vim.g
local fn = vim.fn
local uv = vim.uv
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local myWinPick = require("plugins..config.winpick")

return{
  {
    "gbrlsnchs/winpick.nvim",
    init = function()
      myWinPick.setup()
    end,
    config = function()
      -- api.nvim_create_user_command("WinPick", myWinPick.choose_for_focus, {})
      vim.keymap.set("n", "<Space>w", myWinPick.choose_for_focus)
      --api.nvim_create_user_command("WinExchange", myWinPick.choose_for_move {})
      vim.keymap.set("n", "<Space>m", myWinPick.choose_for_move)
    end,
  },
}
