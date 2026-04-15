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
  local group = augroup("my_ddu", { clear = true })

  -- update items
  autocmd({"BufEnter", "TabEnter", "WinEnter", "CursorHold", "FocusGained"},
    {
      group = group,
      pattern = "*",
      callback = function()
        local filetype = vim.bo.filetype
        if filetype == "ddu-ff" or filetype == "ddu-filer" or filetype == "ddu-ff-filter" then
          return
        end
        if vim.b.ddu_ui_name ~= nil or vim.t.ddu_ui_name ~= nil then
          pcall(vim.fn["ddu#ui#do_action"], "checkItems")
        end
      end,
    }
  )

  -- window resize
  autocmd({"VimResized"},
    {
      group = group,
      pattern = "*",
      callback = ddu.window_resize,
    }
  )
end

return M
