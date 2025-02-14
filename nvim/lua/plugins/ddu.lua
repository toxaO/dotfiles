local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local ddu_action = require("plugins.ddu.action")
local ddu_autocmd = require("plugins.ddu.autocmd")
local ddu_default = require("plugins.ddu.default")
local ddu_keymap = require("plugins.ddu.keymap")
local ddu_ff = require("plugins.ddu.ff")
local ddu_filer = require("plugins.ddu.filer")
local u = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

------------------------------
-- repos
------------------------------

return {

  {"Shougo/ddu.vim",

    dependencies = {
      -- core
      "vim-denops/denops.vim",
      "Shougo/ddu-commands.vim",

      -- ui
      "Shougo/ddu-ui-ff",
      "Shougo/ddu-ui-filer",
      --"matsui54/ddu-vim-ui-select",
      "Omochice/ddu-ui-preview",

      -- source
      "Shougo/ddu-source-file",
      "Shougo/ddu-source-file_rec",
      "shun/ddu-source-rg",
      "Shougo/ddu-source-path_history",
      "matsui54/ddu-source-help",
      "shun/ddu-source-buffer",
      "Shougo/ddu-source-action",
      "kuuote/ddu-source-mr",
      "lambdalisue/mr.vim",
      "matsui54/ddu-source-file_external",
      "uga-rosa/ddu-source-lsp",
      "Shougo/ddu-source-line",
      "Shougo/ddu-source-register",
      "matsui54/ddu-source-command_history",
      "kyoh86/ddu-source-command",
      "mikanIchinose/ddu-source-markdown",
      "suudon0014/ddu-source-arglist",
      "Shougo/ddu-source-dummy",
      "kamecha/ddu-source-tab",
      "kyoh86/ddu-source-quickfix_history",


      -- column
      "Shougo/ddu-column-filename",
      "tamago3keran/ddu-column-devicon_filename",
      "ryota2357/ddu-column-icon_filename",

      -- filter
      "yuki-yano/ddu-filter-fzf",
      "Milly/ddu-filter-kensaku",

        --matcher
      "Shougo/ddu-filter-matcher_files",
      "Shougo/ddu-filter-matcher_substring",
      "Shougo/ddu-filter-matcher_hidden",
      "Shougo/ddu-filter-matcher_relative",
      "Shougo/ddu-filter-matcher_ignore_files",
      "Shougo/ddu-filter-matcher_ignores",

        -- sorter
      "Shougo/ddu-filter-sorter_alpha",
      "Shougo/ddu-filter-sorter_reversed",
      "uga-rosa/ddu-filter-sorter_length",
      "alpaca-tc/ddu-filter-sorter_directory_file",

        -- converter
      "uga-rosa/ddu-filter-converter_devicon",
      "kamecha/ddu-filter-converter_highlight",
      "shutils/ddu-filter-converter_tab",
      "shutils/ddu-filter-converter_remove_display",
      "kamecha/ddu-filter-converter_file_info",
      "Shougo/ddu-filter-converter_display_word",
      "kyoh86/ddu-filter-converter_hl_dir",
      "kamecha/ddu-filter-converter_file_git_status",
      "flow6852/ddu-filter-converter_kind",
      "gamoutatsumi/ddu-filter-converter_relativepath",
      "shutils/ddu-filter-converter_dir_omit_middle",

      -- kind
      "Shougo/ddu-kind-file",
      "Shougo/ddu-kind-word",
    }, -- /dependencies

    config = function ()

      -- init
      ddu.window_resize()

      -- include settings
      ddu_default.setup()
      ddu_ff.setup()
      ddu_filer.setup()
      ddu_keymap.setup()
      ddu_autocmd.reg_autocmd()
      ddu_action.reg_actions()

    end -- /config

  }, -- /plugin name

}
