local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.plugin.config.ddu.core")
local myutils = require("utils")
local km_opts = require("const.keymap")

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

return {

  {"Shougo/ddu.vim",

    dependencies = {
       -- core
       "vim-denops/denops.vim",
       "Shougo/ddu-commands.vim",

       -- ui
       "Shougo/ddu-ui-ff",
       "Shougo/ddu-ui-filer",
       "matsui54/ddu-vim-ui-select",

       -- source
       "Shougo/ddu-source-file",
       "Shougo/ddu-source-file_rec",
       "shun/ddu-source-rg",
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

       -- column
       "Shougo/ddu-column-filename",

       -- filter
       "Shougo/ddu-filter-matcher_substring",
       "yuki-yano/ddu-filter-fzf",

       -- sorter
       "Shougo/ddu-filter-sorter_alpha",

       -- converter
       "uga-rosa/ddu-filter-converter_devicon",

       -- kind
       "Shougo/ddu-kind-file"
    }, -- /dependencies

    config = function ()
      -- window param variables
      local lines = opt.lines:get()
      local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
      local columns = opt.columns:get()
      local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)

      -- ddu default --
      fn["ddu#custom#patch_global"]({
        ui = "ff",
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

            -- window setting
            winHeight= height,
            winWidth= width,
            winRow= row,
            winCol= col,

            -- preview setting
            previewSplit = "vertical",
            previewFloatingTitle = "Preview",
            previewFloating= true,
            previewHeight= height,
            previewWidth= math.floor(width / 2),
            previewFloatingBorder = "rounded",
            startAutoAction = true,
            autoAction = {
              delay = 0,
              name = "preview",
            },

          }, -- /uiParams-ff
          filer = {
          }, -- /uiParams-filer
        }, -- /uiParams
        sourceOptions = {
          _ = {
            ignoreCase = true,
            matchers = {"matcher_substring"},
            sorters = {"sorter_alpha"},
            converters = {"converter_devicon"},
          }, --/sourceOptions-default
        }, -- /sourceOptions

        filterParams = {
          matcher_substring = {
            highlightMatched = "Search",
          }, -- /matcher_substring
          matcher_fzf = {
            highlightMatched = "Search",
          }, -- /matcher_fzf
        }, -- /filterParams

        kindOptions = {
         file = {defaultAction = "open"},
         action = {defaultAction = "do"},
         help = {defaultAction = "open"},
         ui_select = {defaultAction = "do"},
        }, -- /kindOptions
      }) -- /default

      -- ff --
        -- buffer --
      fn["ddu#custom#patch_local"]("buffer",{
        sources = {{name = "buffer"}},
        uiParams = {
          ff = {startFilter = false},
        }
      }) -- /buffer --

       -- project all file --
      fn["ddu#custom#patch_local"]("project", {
        sources = {{name = "file_rec"},},
        sourceOptions = {
          file_rec = {path = myutils.fs.get_project_root_current_buf()}
        },
        sourceParams = {
          file_rec = {
            ignoreDirectories = {
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
      }) -- /project all file --

        -- project grep --
      fn["ddu#custom#patch_local"]("project_grep", {
        sources = {
          {name = "file_rec"},
          {name = "rg"},
        },
        sourceOptions = {
          file_rec = {
            path = myutils.fs.get_project_root_current_buf()
          },
          rg = {
            matchers = {},
            volatile = true,
          },
        },
        sourceParams = {
          rg = {
            args = {"--column", "--no-heading", "--color", "never"},
            input = fn["expand"]("<cword>"),
          },
        },
      }) -- /project grep

        -- help --
      fn["ddu#custom#patch_local"]("help",{
        sources = {{name = "help",}},
        sourceParams = {
          helpLang = "ja",
        },
      }) -- /help --

      -- /ff --

      -- filer --

      -- ddu keymaps --
        -- ff keymaps --
          -- ff normal keymaps --

			local ddu_ff_keymap = vim.api.nvim_create_augroup("ddu_ff_keymap", { clear = true })
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff",
        callback = function()
          keymap.set("n", "<CR>", function()
            fn["ddu#ui#do_action"]("itemAction")
          end, km_opts.bn)
          keymap.set("n", "<Space>", function()
            fn["ddu#ui#do_action"]("toggleSelectItem")
          end, km_opts.bn)
          keymap.set("n", "i", function()
            fn["ddu#ui#do_action"]("openFilterWindow")
          end, km_opts.bn)
          keymap.set("n", "p", function()
            fn["ddu#ui#do_action"]("preview")
          end, km_opts.bn)
          keymap.set("n", "q", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bn)
          keymap.set("n", "<C-C>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bn)
          keymap.set("n", "a", function()
            fn["ddu#ui#do_action"]("chooseAction")
          end, km_opts.bn)

          keymap.set("n", "v", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "vsplit" } })
          end, km_opts.bn)
          keymap.set("n", "s", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "split" } })
          end, km_opts.bn)
          keymap.set("n", "t", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tabe" } })
          end, km_opts.bn)
        end,
      })
          -- /ff normal keymaps --
          -- ff filtering keymaps --
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff-filter",
        callback = function()
          keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], km_opts.bn)
          keymap.set({ "n", "i" }, "<C-C>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bn)
        end,
      })
          -- /ff filtering keymaps --
        -- /ff keymaps --
        -- filer keymaps --
        -- /filer keymaps --
      -- /ddu keymaps --

    end -- /config
  }, -- /plugin name
}
