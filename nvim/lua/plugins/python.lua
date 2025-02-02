local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

  -- python to test
  { "tpope/vim-dispatch" },

  { "radenling/vim-dispatch-neovim" },

  { "janko-m/vim-test",
    dependencies = "vim-dispatch",
    config = function ()
      g["test#strategy"] = "dispatch"
    end},

  { "aliev/vim-compiler-python",
    config = function()
      vim.env["PYTHONWARNINGS"] = "ignore"
      g["python_compiler_fixqflist"] = 1
    end},

}
