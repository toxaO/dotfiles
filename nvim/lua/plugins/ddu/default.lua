local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local ddu_action = require("plugins.ddu.action")
local ddu_autocmd = require("plugins.ddu.autocmd")
local u = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local M = {
}

function M.setup()
  -- ddu global setting -> default
  ddu.patch_global({
    -- default ui --
    ui = "ff",

    -- ui-ff params -> ff
    -- paramsは分ける
    uiParams = {

      ff = {
        split = "floating",
        highlights = {
          floating = "Pmenu",
          floatingBorder = "Pmenu",
        },

        floatingBorder = "rounded",
        filterFloatingPosition = "top",
        filterSplitDirection = "floating",
        prompt = ">>",
        startFilter =  true,

        -- preview setting
        previewFloatingTitle = "Preview",
        previewFloating= true,
        previewFloatingBorder = "rounded",
        startAutoAction = false,
        autoAction = {
          delay = 0,
          name = "preview",
        },

      }, -- /ui-ff params
    }, -- /ui params

    sourceOptions = {
      _ = { -- ->default
        ignoreCase = true,

        matchers = {
          "matcher_substring",
          "matcher_hidden",
        },

        sorters = {"sorter_alpha"},

        converters = {
          "converter_devicon",
          "converter_dir_omit_middle",
          "converter_relativepath",
          "converter_hl_dir",
        },

      }, --/sourceOptions-default

      buffer = {sorters = {},},
      action = {matchers = {}}, -- source-actionにmatcher-hiddenを入れるとsourceが取れない

      file_rec = {
        matchers = {"matcher_fzf"},
        sorters = {"sorter_fzf"},
      }, -- /sourceOptions-file_rec

    }, -- /sourceOptions

    filterParams = {

      matcher_substring = { highlightMatched = "Search", }, -- /matcher_substring

      matcher_fzf = { highlightMatched = "Search", }, -- /matcher_fzf

    }, -- /filterParams

    kindOptions = {
      file = {defaultAction = "open"},
      action = {defaultAction = "do"},
      help = {defaultAction = "open"},
      ui_select = {defaultAction = "do"},
    }, -- /kindOptions

  }) -- /default

end

return M
