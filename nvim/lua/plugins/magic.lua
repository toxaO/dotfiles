
local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {
  {"kawarimidoll/magic.vim",
    keys = {
        { '<C-x>', function() vim.fn['magic#expr']() end, mode = 'c' },
    },
  }
}
