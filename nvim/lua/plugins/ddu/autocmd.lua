local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local ddu_action = require("plugins.ddu.action")
local u = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
local augroup = vim.api.nvim_create_augroup -- Create autocommand

local M = {
}

------------------------------
-- auto commands
------------------------------

function M.reg_autocmd()
  augroup("my_ddu", { clear = true })

  -- update items
  autocmd({"BufEnter", "TabEnter", "WinEnter", "CursorHold", "FocusGained"},
    {
      group = my_ddu,
      pattern = "*",
      command = "call ddu#ui#do_action('checkItems')"
    }
  )

  -- window resize
  autocmd({"VimResized"},
    {
      group = my_ddu,
      pattern = "*",
      callback = ddu.window_resize,
    }
  )
end

return M
