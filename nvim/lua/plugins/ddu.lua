local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.config.ddu.core")
local myutils = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand


-- ddu custom functions --
local function toggle(array, needle)
  local idx = -1
  for k, v in ipairs(array) do
    if v == needle then idx = k end
  end
  if idx ~= -1 then
    table.remove(array, idx)
  else
    table.insert(array, needle)
  end
  --print(vim.inspect(array))
  return array
end

local function toggleHidden(ui_name, source_name)
  local cur = vim.fn['ddu#custom#get_current'](ui_name)
  local opts = cur['sourceOptions'] or {}
  local opts_all = opts[source_name] or {}
  local matchers = opts_all['matchers'] or {}
  --print(vim.inspect(matchers))
  return toggle(matchers, 'matcher_hidden')
end

-- /ddu custom functions --

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
      -- ddu default --
        -- ddu window size --
      local function ddu_window_resize()
        -- window param variables
        local lines = opt.lines:get()
        local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
        local columns = opt.columns:get()
        local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)

        fn["ddu#custom#patch_global"]({
          -- ui-ff params --
          uiParams = {
            ff = {
              -- window setting
              winHeight= height,
              winWidth= width,
              winRow= row,
              winCol= col,
            }, -- /ui-ff params
          }, -- /ui params
        })

          -- preview size --
        if width > 155 then
          fn["ddu#custom#patch_global"]({
            -- ui-ff params --
            uiParams = {
              ff = {
                -- preview setting
                previewSplit = "vertical",
                previewHeight= height,
                previewWidth= math.floor(width / 2),
              }, -- /ui-ff params

              filer = {
                -- preview setting
                previewHeight= height,
                previewWidth= math.floor(width / 2),
              }
            }, -- /ui params
          })
        else
          fn["ddu#custom#patch_global"]({
            -- ui-ff params --
            uiParams = {
              ff = {
                -- preview setting
                previewSplit = "horizontal",
                previewHeight= math.floor(height / 2),
                previewWidth= width,
                previewRow = lines - 5,
              }, -- /ui-ff params

              filer = {
                -- preview setting
                previewHeight= height,
                previewWidth= width,
              }
            }, -- /ui params
          })

        end
      end

      -- initial window size setting --
      ddu_window_resize()


      -- ddu global setting --
      fn["ddu#custom#patch_global"]({
        -- default ui --
        ui = "ff",

        -- ui-ff params --
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
          _ = {
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
      }) -- /buffer --

        -- args --
      fn["ddu#custom#patch_local"]("args",{
        sources = {{name = "arglist"}},
      }) -- /args --

        -- file_rec --
      fn["ddu#custom#patch_local"]("file_rec",{
        sources = {
          {name = "file_rec"},
        },
        sourceParams = {
          file_rec = {
            ignoredDirectories = {
              ".git",
              "node_modules",
              "vendor",
              ".next",
              ".venv",
              "__pycache__",
              ".mypy_cache",
              "out",
            },
          },
        },
      }) -- /file_rec --

       -- project all file --
      fn["ddu#custom#patch_local"]("project", {
        sources = {
          {name = "file_rec"},
        },
        sourceOptions = {
--          file_rec = {path = fn["expand"](myutils.fs.get_project_root_current_buf())}
        },
        sourceParams = {
          file_rec = {
            ignoredDirectories = {
              ".git",
              "node_modules",
              "vendor",
              ".next",
              ".venv",
              "__pycache__",
              ".mypy_cache",
              "out",
            },
          },
        },
      }) -- /project all file --

        -- project grep --
      fn["ddu#custom#patch_local"]("project_grep", {
        uiParams = {
          ff = {
            ignoreEmpty = false,
            autoResize = false,
          },
        },
        sources = {
          --{name = "file_rec"},
          {name = "rg"},
        },
        sourceOptions = {
          file_rec = {
 --           path = myutils.fs.get_project_root_current_buf()
          },
          rg = {
            matchers = {},
            volatile = true,
          },
        },
        sourceParams = {
          rg = {
            args = {"--column", "--no-heading", "--color", "never"},
            --input = fn["expand"]("<cword>"),
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

      -- /ff setting --

      -- filer setting --
        -- filer ui params --

      local filer_ui = {
        filer = {
          winWidth = 40,
          split = "vertical",
          splitDirection = "topleft",
          sort = "filename",
          sortTreesFirst = true,

          -- preview setting
          previewSplit = "vertical",
          previewFloatingTitle = "Preview",
          previewFloating= true,
          previewFloatingBorder = "rounded"}}

      local filer_sourceOptions = {
        ["_"] = {
          --columns = {"devicon_filename"},
          columns = {"icon_filename"},
          converters = {},
        },
      }

      local filer_columnParams = {
        icon_filename = {
          span = 2,
          padding = 2,
          iconWidth = 2,
          useLinkIcon = "grayout",
          sort = "filename",
          sortTreesFirst = true,
        },
      }

      local filer_actionOptions = {
          narrow = { quit = false, },
          cd = {quit = false},
        }

      local filer_default = {
        ui = "filer",
        uiParams = filer_ui ,
        sources = { {name = "file"} },
        sourceOptions =  filer_sourceOptions ,
        sourceParams = {},
        columnParams = filer_columnParams,
        actionOptions = filer_actionOptions,
        resume = true,
        sync = true,
      }

      fn["ddu#custom#patch_local"]("filer", filer_default)
      -- /filer setting --

      -- ddu keymaps --
        -- common keymaps --
      local function common_keymap()
          -- <CR> open --
          keymap.set("n", "<CR>", function()
            return ddu.item.is_tree() and ddu.do_action("itemAction", { name = "narrow" })
            and fn["ddu#ui#do_action"]("cursorNext")
            or ddu.do_action("itemAction", { quit = true })
          end, km_opts.bnw)

          -- buffer open --
          keymap.set("n", "b", function()
            ddu.do_action("itemAction", { name = "open", quit = false })
          end, km_opts.bnw)

          -- cursor --
          keymap.set("n", "j", function()
            b.multiCursorSelection = 0
            b.SelectStartLine = 0
            fn["ddu#ui#do_action"]("cursorNext", {loop = true})
          end, km_opts.bnw)
          keymap.set("n", "k", function()
            b.multiCursorSelection = 0
            b.SelectStartLine = 0
            fn["ddu#ui#do_action"]("cursorPrevious", {loop = true})
          end, km_opts.bnw)
          -- /cursor --

          -- "v" vsplit --
          keymap.set("n", "v", function()
            return ddu.item.is_tree() and ddu.do_action("expandItem")
            or ddu.do_action("itemAction", { name = "open", params = { command = "vsplit" } })
          end, km_opts.bnw)
          -- "s" split --
          keymap.set("n", "s", function()
            return ddu.item.is_tree() and ddu.do_action("expandItem")
            or ddu.do_action("itemAction", { name = "open", params = { command = "split" } })
          end, km_opts.bnw)
          -- "t" tabnew --
          keymap.set("n", "t", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tabe" } })
          end, km_opts.bnw)

          -- "w" window choose --
          keymap.set("n", "w", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "window_choose" })
          end, km_opts.bnw)

          -- "q" quit --
          keymap.set("n", "q", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bnw)
          -- <C-C> cancel --
          keymap.set({"n", "i"}, "<C-C>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bnw)
          --  <Esc> Escape --
          keymap.set("n", "<Esc>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bnw)

          -- "a" choose action --
          keymap.set("n", "a", function()
            fn["ddu#ui#do_action"]("chooseAction")
          end, km_opts.bnw)

          -- "o" expand --
          keymap.set("n", "o", function()
            fn["ddu#ui#do_action"]("expandItem", {mode = "toggle"})
          end, km_opts.bnw)
          -- "O" all expand --
          keymap.set("n", "O", function()
            fn["ddu#ui#do_action"]("expandItem", {mode = "toggle", maxLevel = -1})
          end, km_opts.bnw)
          -- "r" rename --
          keymap.set("n", "r", function()
            ddu.do_action("itemAction", { name = "rename" })
          end, km_opts.bnw)
          -- "C" cd --
          keymap.set("n", "C", function()
            local path = fn["ddu#ui#get_item"]()["action"]["path"]
            print('change to "' .. path .. '" !')
            ddu.do_action("itemAction", { name = "cd" })
          end, km_opts.bnw)
          -- "c" copy --
          keymap.set("n", "c", function()
            fn["ddu#ui#multi_actions"]({ {"itemAction", {name = "copy"}}, {"clearSelectAllItems"} })
          end, km_opts.bnw)
          -- "x" cut --
          keymap.set("n", "x", function()
            ddu.do_action("itemAction", { name = "cut" })
          end, km_opts.bnw)
          -- "X" excution --
          keymap.set("n", "X", function()
            ddu.do_action("itemAction", { name = "executeSystem" })
          end, km_opts.bnw)
          -- "P" --
          keymap.set("n", "P", function()
            ddu.do_action("itemAction", { name = "paste" })
          end, km_opts.bnw)
          -- "m" --
          keymap.set("n", "m", function()
            ddu.do_action("itemAction", { name = "move" })
          end, km_opts.bnw)
          -- "n" --
          keymap.set("n", "n", function()
            ddu.do_action("itemAction", { name = "newFile" })
          end, km_opts.bnw)
          -- "N" --
          keymap.set("n", "N", function()
            ddu.do_action("itemAction", { name = "newDirectory" })
          end, km_opts.bnw)
          -- "y" --
          keymap.set("n", "y", function()
            fn["ddu#ui#multi_actions"]({ {"itemAction", {name = "yank"}}, {"clearSelectAllItems"} })
          end, km_opts.bnw)
          -- "d" --
          keymap.set("n", "d", function()
            ddu.do_action("itemAction", { name = "trash" })
          end, km_opts.bnw)
          -- "D" --
          keymap.set("n", "D", function()
            ddu.do_action("itemAction", { name = "delete" })
          end, km_opts.bnw)
          -- "<C-l>" --
          keymap.set("n", "<C-L>", function()
            ddu.do_action("checkItems")
          end, km_opts.bnw)
          -- "." --
          vim.keymap.set('n', '.', function()
            ddu.do_action('updateOptions', {
              sourceOptions = {
                file = {
                  matchers = toggleHidden(vim.b.ddu_ui_name, "file")
                },
              },
            })
            ddu.do_action("checkItems")
            ddu.do_action("redraw")
          end, km_opts.ebsw)
          -- /action --
      end -- /common keymaps

        -- ff keymaps --
          -- ff normal keymaps --

			local ddu_ff_keymap = vim.api.nvim_create_augroup("ddu_ff_keymap", { clear = true })
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff",
        callback = function()
          -- common --
          common_keymap()
          -- selection --
          keymap.set("n", "l", function()
            fn["ddu#ui#do_action"]("toggleSelectItem")
          end, km_opts.bnw)
          keymap.set("n", "L", function()
            fn["ddu#ui#do_action"]("clearSelectAllItems")
          end, km_opts.bnw)
          keymap.set("n", "*", function()
            fn["ddu#ui#do_action"]("toggleSelectItem")
          end, km_opts.bnw)
          -- /selection --
          -- shift cursor --
          keymap.set("n", "J", function()
            -- 選択開始の状態 --
            if b.SelectStartLine == 0 or b.SelectStartLine == nil then
              b.SelectStartLine = fn["getpos"](".")[2]
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
              ddu.do_action("toggleSelectItem")
            -- カーソルが選択開始より上にいる --
            elseif fn["getpos"](".")[2] < b.SelectStartLine then
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
            -- カーソルが選択開始以下にいる --
            elseif b.SelectStartLine <= fn["getpos"](".")[2] then
              ddu.do_action("cursorNext")
              ddu.do_action("toggleSelectItem")
            end
          end, km_opts.bnw)
          keymap.set("n", "K", function()
            -- 選択開始 --
            if b.SelectStartLine == 0 or b.SelectStartLine == nil then
              b.SelectStartLine = fn["getpos"](".")[2]
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
              ddu.do_action("toggleSelectItem")
            -- カーソルが選択開始以上にいる --
            elseif fn["getpos"](".")[2] <= b.SelectStartLine then
              ddu.do_action("cursorPrevious")
              ddu.do_action("toggleSelectItem")
            -- カーソルが選択開始より下にいる --
            elseif b.SelectStartLine < fn["getpos"](".")[2] then
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
            end
          end, km_opts.bnw)
          -- /shift cursor --

          -- filtering --
          keymap.set("n", "i", function()
            fn["ddu#ui#do_action"]("openFilterWindow")
          end, km_opts.bnw)

          -- "p" preview --
          keymap.set("n", "p", function()
            fn["ddu#ui#do_action"]("toggleAutoAction")
          end, km_opts.bnw)

        end,
      })
          -- /ff normal keymaps --
          -- ff filtering keymaps --
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff-filter",
        callback = function()
          keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], km_opts.bnw)
          keymap.set({ "n", "i" }, "<C-C>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bnw)
          keymap.set("n", "<Esc>", function()
            fn["ddu#ui#do_action"]("quit")
          end, km_opts.bnw)
        end,
      })
          -- /ff filtering keymaps --
        -- /ff keymaps --

        -- filer keymaps --
			local ddu_filer_keymap = vim.api.nvim_create_augroup("ddu_filer_keymap", { clear = true })
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_filer_keymap,
        pattern = "ddu-filer",
        callback = function()
          -- common --
          common_keymap()
          -- "w" --
          keymap.set("n", "w", function()
            fn["ddu#ui#do_action"]("itemAction", { name = "window_choose" })
          end, km_opts.bnw)
          -- /open --

          -- selection --
          -- "l" --
          keymap.set("n", "l", function()
            fn["ddu#ui#do_action"]("toggleSelectItem")
          end, km_opts.bnw)
          -- "L" --
          keymap.set("n", "L", function()
            fn["ddu#ui#do_action"]("clearSelectAllItems")
          end, km_opts.bnw)
          -- "*" --
          keymap.set("n", "*", function()
            fn["ddu#ui#do_action"]("toggleAllItems")
          end, km_opts.bnw)
          -- /selection --
          -- shift cursor --
          keymap.set("n", "J", function()
            -- 選択開始の状態 --
            if b.SelectStartLine == 0 or b.SelectStartLine == nil then
              b.SelectStartLine = fn["getpos"](".")[2]
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
            -- カーソルが選択開始より上にいる --
            elseif fn["getpos"](".")[2] < b.SelectStartLine then
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
            -- カーソルが選択開始以下にいる --
            elseif b.SelectStartLine <= fn["getpos"](".")[2] then
              ddu.do_action("cursorNext")
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorNext")
            end
          end, km_opts.bnw)
          keymap.set("n", "K", function()
            -- 選択開始 --
            if b.SelectStartLine == 0 or b.SelectStartLine == nil then
              b.SelectStartLine = fn["getpos"](".")[2]
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
            -- カーソルが選択開始以上にいる --
            elseif fn["getpos"](".")[2] <= b.SelectStartLine then
              ddu.do_action("cursorPrevious")
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
            -- カーソルが選択開始より下にいる --
            elseif b.SelectStartLine < fn["getpos"](".")[2] then
              ddu.do_action("toggleSelectItem")
              ddu.do_action("cursorPrevious")
            end
          end, km_opts.bnw)
          -- /shift cursor --

          -- "i" --
          keymap.set("n", "i", function()
            local path = fn["fnamemodify"](fn["input"]("cwd: ", b.ddu_ui_filer_path, "file"), ":p")
              fn["ddu#ui#do_action"]("itemAction",
                  {
                    name = "narrow",
                    params = {
                      path = path,
                    }
                  }
                )
            fn["ddu#ui#do_action"]("cursorNext")
          end, km_opts.bnw)

          -- "p" preview --
          keymap.set("n", "p", function()
            fn["ddu#ui#do_action"]("togglePreview")
          end, km_opts.bnw)

          -- "f" --
          keymap.set("n", "f",function()
            local path = fn["ddu#ui#get_item"]()["action"]["path"]
            fn["ddu#ui#do_action"]("quit")
            fn["ddu#start"]({
              name = "file_rec",
              sourceOptions = {
                _ = {
                  path = path
                },
              }
            })
          end, km_opts.bnw)

          -- "^" --
          keymap.set("n", "^", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand(g.my_initvim_path) } })
          end, km_opts.bnw)
          -- "\" --
          keymap.set("n", ",", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~/dotfiles/mydotfiles") } })
          end, km_opts.bnw)
          -- "|" --
          keymap.set("n", "|", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~/repos") } })
          end, km_opts.bnw)
          -- "~" --
          keymap.set("n", "~", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = fn.expand("~") } })
          end, km_opts.bnw)
          -- "=" --
          keymap.set("n", "=", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = fn["getcwd"]() } })
          end, km_opts.bnw)
          -- <BS> --
          keymap.set("n", "<BS>", function()
            ddu.do_action("itemAction", { name = "narrow", params = { path = ".." } })
          end, km_opts.bnw)

        end,
      })
        -- /filer keymaps --
      -- /ddu keymaps --

      fn["ddu#custom#action"]("kind", "file", "argadd", function(args)
        local arglist = {}
        for _, item in ipairs(args.items) do
          local path = item.action.path
          if item.action.isDirectory then
            path = path .. "/**"
          end
          table.insert(arglist, path)
        end
        vim.cmd.args(arglist)
        return 4
      end)

      fn["ddu#custom#action"]("kind", "file", "window_choose", function(args)
        myutils.io.debug_echo("args", args.items)
        return ddu.window_choose(args)
      end)

      keymap.set("n", "<Space>b",":call ddu#start(#{name: 'buffer'})<CR>", km_opts.nsw)
      keymap.set("n", "<Space>a",":call ddu#start(#{name: 'args'})<CR>", km_opts.nsw)
      keymap.set("n", "<Space>f",":call ddu#start(#{name: 'file_rec'})<CR>", km_opts.nsw)
      keymap.set("n", "<Space>h",
        ":call ddu#start(#{name: 'file_rec', sources: [#{name: 'path_history'}]})<CR>", km_opts.nsw)
      keymap.set("n", "<Space>p",function()
        fn["ddu#start"]({
          name = "file_rec",
          sourceOptions = {
            _ = {
              path = fn["expand"](b.project_root)
            },
          },
        })
      end, km_opts.nsw)
      keymap.set("n", "<F1>",":call ddu#start(#{name: 'help'})<CR>", km_opts.nsw)
      keymap.set("n", "<Space>g",function()
        fn["ddu#start"]({
          name = "project_grep",
          sourceOptions = {
            _ = {
              path = fn["expand"](b.project_root)
            },
          },
          input = fn["expand"]("<cword>"),
        })
      end, km_opts.nsw)

      -- filer start --
      keymap.set("n", "<Space>e", function()
        local filer_name = vim.t.ddu_ui_filer_path or fn["getcwd"]()
        filer_default.name = "filer_" .. fn["win_getid"]()
        filer_default.sourceOptions.file = {path = filer_name}
        fn["ddu#start"]( filer_default )
        fn["ddu#ui#do_action"]("cursorNext")
      end, km_opts.nsw)

      -- autocmd --
      autocmd({"BufEnter", "TabEnter", "WinEnter", "CursorHold", "FocusGained"},
        {
          group = my_augroup,
          pattern = "*",
          command = "call ddu#ui#do_action('checkItems')"
        }
      )
      autocmd({"VimResized"},
        {
          group = my_augroup,
          pattern = "*",
          callback = ddu_window_resize,
        }
      )
    end -- /config
  }, -- /plugin name
}
