
local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

  { "sindrets/diffview.nvim",
    config = function ()
      keymap.set("n", "<leader>hd", "<cmd>DiffviewOpen HEAD~1<CR>", silent)
      keymap.set("n", "<leader>hf", "<cmd>DiffviewFileHistory %<CR>", silent)
    end
  },

}
