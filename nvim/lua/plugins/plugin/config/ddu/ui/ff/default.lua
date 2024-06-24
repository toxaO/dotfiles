local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")
--local lsplist = require("plugins.plugin.indevidual.lsplist")
local ddu = require("plugins.plugin.config.ddu")

local M = {}

local lines = vim.opt.lines:get()
local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
local columns = vim.opt.columns:get()
local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)


function M.setup()
  fn["ddu#custom#patch_global"]({
    ui = "ff",
    uiParams = {
      ff = {
        split = "floating",
        filterFloatingPosition = "top",
        filterSplitDirection = "floating",
        floatingBorder = 'rounded',
        prompt = ">",
        startFilter = true,

        winHeight= height,
        winWidth= width,
        winRow= row,
        winCol= col,
        previewSplit = "vertical",
        previewFloatingTitle = "Preview",
        previewFloating= true,
        previewHeight= height,
        previewWidth= math.floor(width / 2),
        previewFloatingBorder = "rounded",
        highlights = {
          floating = "Pmenu",
          floatingBorder = "Pmenu",
        },
      },
    },
    sources = {
      {
        name = "file_rec",
        params = {
          ignoredDirectories = {
            ".git",
            "node_modules",
            "vendor",
            ".next",
            ".venv",
            "__pycache__",
            ".mypy_cache",
          },
        },
      },
    },
    sourceOptions = {
      _ = {
        ignoreCase = true,
        matchers = {
          --"matcher_substring",
          "matcher_fzf",
        },
        sorters = {
          "sorter_fzf",
        },
        converters = {
          "converter_devicon",
        },
        volatile = true,
      },
    },
    filterParams = {
      --matcher_substring = {
      --  highlightMatched = "Title",
      --},
      matcher_fzf = {
        highlightMatched = "Search",
      },
    },
    kindOptions = {
      file = {
        defaultAction = "open",
      },
      action = {
        defaultAction = "do",
      },
    },
  })
end


return M
