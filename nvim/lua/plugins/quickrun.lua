local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {
  {
    "thinca/vim-quickrun",
    config = function ()
      g.quickrun_config = {
        _ = {
          ["outputter"] = "error",
          ["outputter/error/success"] = "buffer",
          ["outputter/error/error"] = "quickfix",
          ["outputter/buffer/opener"] = ":botright 8sp",
          ["outputter/buffer/close_on_empty"] = 1,
          ["runner"] = "vimproc",
          ["runner/vimproc/updatetime"] = 60,
          -- ["hook/time/enable"] = 1,
        }
      }
    end
  },

  {
    "Shougo/vimproc.vim",
    build = "make"
  },


}
