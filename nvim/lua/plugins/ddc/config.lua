local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local patch_global=vim.fn["ddc#custom#patch_global"]

local M = {}

function M.setup()
  -- ui --
  patch_global("ui", "pum")

  -- auto start event --
  patch_global("autoCompleteEvents", {
    "InsertEnter",
    "TextChangedI",
    "TextChangedP",
    "CmdlineChanged",
    "CmdlineEnter",
    "TextChangedT",
  })

  -- source --
  patch_global("sources", {
    "lsp",
    "around",
    "file",
    'mocword',
    "skkeleton",
  })

  -- source options --
  patch_global("sourceOptions", {

    _ = {
      matchers = { "matcher_fuzzy" },
      sorters = { "sorter_fuzzy", "sorter_rank" },
      converters = { "converter_remove_overlap", "converter_fuzzy" },
      minAutoCompleteLength = 3,
    },

    around = {
      mark = "[Around]",
    },

    file = {
      mark = "[file]",
      isVolatile = true,
      forceCompletionPattern = "\\S/\\S*", -- \Sは空白以外の文字
    },

    mocword = {
      mark = "[Moc]",
      maxItems = 10,
      isVolatile = true,
      minAutoCompleteLength = 4,
    },

    lsp = {
      mark = "[LSP]",
      forceCompletionPattern = { [[\.\w*|:\w*|->\w*]] },
      sorters = { "sorter_lsp-kind" },
      minAutoCompleteLength = 1,
    },

    skkeleton = {
      mark = "[SKK]",
      matchers = {},
      sorters = {},
      converters = {},
      isVolatile = true,
      minAutoCompleteLength = 1,
    },
  })

  -- source param
  patch_global("sourceParams", {
    ["lsp"] = {
      --snippetEngine = vim.fn["denops#callback#register"](function(body)
        --vim.fn["vsnip#anonymous"](body)
      --end),
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
    },
  })

  --vim.g.vsnip_filetypes = {}
  fn["ddc#enable_terminal_completion"]()

end

return M
