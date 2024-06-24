local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local myutils = require("utils")

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local M = {}

function M.setup()
  --------------------------------------------------------------------------------
  -- define augroup
  --------------------------------------------------------------------------------
  augroup("my_augroup", { clear = true })
  augroup("my_colorscheme", { clear = true })

  --------------------------------------------------------------------------------
  -- Remove whitespace on save
  --------------------------------------------------------------------------------
  autocmd("BufWritePre", {
    group = my_augroup,
    pattern = "*",
    command = ":%s/\\s\\+$//e",
  })

  --------------------------------------------------------------------------------
  -- adjust scroll off
  --------------------------------------------------------------------------------
  autocmd("WinScrolled", {
    group = my_augroup,
    pattern = "*",
    callback = function()
      local lines = fn["winheight"](0)
      local scrolloff = math.floor(lines / 7)
      vim.opt["scrolloff"] = scrolloff

      local width = fn["winwidth"](0)
      local sidescrolloff = math.floor(width / 25)
      vim.opt["sidescrolloff"] = sidescrolloff
    end
  })

  --------------------------------------------------------------------------------
  -- Don't auto commenting new lines
  --------------------------------------------------------------------------------
  autocmd("BufEnter", {
    group = my_augroup,
    pattern = "*",
    command = "set fo-=c fo-=r fo-=o",
  })

  --------------------------------------------------------------------------------
  -- set project_root
  --------------------------------------------------------------------------------
  autocmd({ "DirChanged" , "BufEnter"}, {
    group = my_augroup,
    pattern = "*",
    callback = function()
      b.project_root = myutils.fs.get_project_root_current_buf()
    end
  })

  --------------------------------------------------------------------------------
  -- commandline window --
  -- 余計なものを消す --
  --------------------------------------------------------------------------------
  autocmd("CmdwinEnter", {
    group = my_augroup,
    pattern = {":", "/", "?", "="},
    callback = function()
      vim.cmd([[silent g/^qa\?!\?$/de]])
      vim.cmd([[silent g/^wq\?a\?!\?$/de]])
      vim.cmd([[silent g/^\d*$/de]])
      vim.cmd([[setlocal nonumber]])
      vim.cmd([[setlocal signcolumn=no]])
    end
  })

  --------------------------------------------------------------------------------
  -- quickfix window --
  --------------------------------------------------------------------------------
  autocmd("QuickFixCmdPost", {
    group = my_augroup,
    pattern = {"*grep*"},
    callback = function()
      vim.cmd([[cwindow]])
    end})

  --------------------------------------------------------------------------------
  -- python indent --
  --------------------------------------------------------------------------------

end

return M
