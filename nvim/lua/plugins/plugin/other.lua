return {

	{ "vim-jp/vimdoc-ja", lazy = true, keys = {
		{ "h", mode = "c" },
	} },

	"cocopon/iceberg.vim",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "ryanoasis/vim-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},
	{
		"nanozuki/tabby.nvim",
		config = function()
			vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

			local theme = {
				fill = "TabLineFill",
				-- Also you can do this:
				--fill = { fg='#f2e9de', bg='#907aa9', style='italic' },
				head = "TabLine",
				current_tab = "TabLineSel",
				--current_tab = { fg='#f1e8de', bg='#907aa9', style='italic' },
				tab = "TabLine",
				--current_win = { fg='#f2e9de', bg='#907aa9', style='italic' },
				current_win = "TabLineSel",
				win = "TabLine",
				tail = "TabLine",
			}
			require("tabby.tabline").set(function(line)
				return {
					{
						{ "  ", hl = theme.head },
						line.sep("", theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl_tab = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl_tab, theme.fill),
							tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep("", hl_tab, theme.fill),
							hl = hl_tab,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
						local hl_win = win.is_current() and theme.current_win or theme.win
						return {
							line.sep("", hl_win, theme.fill),
							win.is_current() and "" or "",
							win.buf_name(),
							line.sep("", hl_win, theme.fill),
							hl = hl_win,
							margin = " ",
						}
					end),
					{
						line.sep("", theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end)
		end,
	},

	"ryanoasis/vim-devicons",
	{ "nvim-tree/nvim-web-devicons" },
	{ "simeji/winresizer", lazy = true, cmd = { "WinResizerStartResize" }, keys = { "<C-E>", mode = "n" } },

--------------------------------------------------
	-- LSP
	{ "neovim/nvim-lspconfig"},
	{
		"williamboman/mason.nvim",
		config = function()
			--require'lspconfig'.pyright.setup{}
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "rust_analyzer" },
			})

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					local highlight_variable = function(client, bufnr)
						if client.supports_method("textDocument/document_highlight") then
							local lsp_document_highlight = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
							vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
								group = lsp_document_highlight,
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.document_highlight()
								end,
							})
							vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
								group = lsp_document_highlight,
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.clear_references()
								end,
							})
						end
					end

					local lsp_opts = {
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							local set = vim.keymap.set
							set("n", "<Space>ld", "<cmd>lua vim.lsp.buf.definition()<CR>")
							set("n", "<Space>lD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
							set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
							set("n", "<Space>li", "<cmd>lua vim.lsp.buf.implementation()<CR>")
							set("n", "<Space>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
							set("n", "<Space>ln", "<cmd>lua vim.lsp.buf.rename()<CR>")
							set("n", "<Space>la", "<cmd>lua vim.lsp.buf.code_action()<CR>")
							set("n", "<Space>lr", "<cmd>lua vim.lsp.buf.references()<CR>")
							set("n", "<Space>ll", '<cmd>lua vim.stic.open_float({scope="line"})<CR>')
							set("n", "<Space>ls", "<cmd>lua vim.diagnostic.open_float()<CR>")
							set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
							set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
							set("n", "<Space>lf", "<cmd>lua vim.lsp.buf.format()<CR>")
							highlight_variable(client, bufnr)
						end,
					}

					if server_name == "lua_ls" then
						lsp_opts.settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
							},
						}
					end

					require("lspconfig")[server_name].setup(lsp_opts)
				end,
			})
		end,
	},

--------------------------------------------------
	-- dark powered
	-- denops関係は非同期読み込みのため、遅延の必要なし
	"vim-denops/denops.vim",
	{ "Shougo/ddc.vim", dependencies = { "vim-denops/denops.vim" } },
	"Shougo/pum.vim",

	-- ddc ui
	{ "Shougo/ddc-ui-pum" },
	{ "Shougo/ddc-ui-native" },
	-- ddc lsp
	{ "uga-rosa/ddc-source-lsp-setup" },
	{
		"Shougo/ddc-source-lsp",
		config = function()
			require("ddc_source_lsp_setup").setup()
			local capabilities = require("ddc_source_lsp").make_client_capabilities()
			require("lspconfig").denols.setup({
				capabilities = capabilities,
			})
		end,
	},
	-- ddc source
	{ "matsui54/ddc-buffer" },
	{ "Shougo/ddc-source-around" },
	{ "LumaKernel/ddc-source-file" },
	{ "Shougo/ddc-source-cmdline" },
	{ "Shougo/ddc-source-cmdline-history" },
	{ "Shougo/ddc-source-input" },
	{ "Shougo/ddc-source-rg" },
	{ "Shougo/ddc-source-omni" },
	{ "Shougo/ddc-source-mocword" },
	{ "matsui54/ddc-dictionary" },
	{ "Shougo/ddc-source-copilot" },
	{ "Shougo/ddc-source-line" },
	{ "tani/ddc-fuzzy" },
	-- ddc filter
	{ "Shougo/ddc-filter-sorter_rank" },
	{ "Shougo/ddc-filter-matcher_head" },
	-- ddc matcher
	{ "matsui54/ddc-matcher_fuzzy" },
	-- ddc converter
	{ "Shougo/ddc-filter-converter_remove_overlap" },
	-- ddc-hover
	{
		"matsui54/denops-signature_help",
		config = function()
			-- denops-signature_help
			vim.g.signature_help_config = {
				contentsStyle = "full",
				viewStyle = "floating",
			}
			vim.fn["signature_help#enable"]()
		end,
	},
	{
		"matsui54/denops-popup-preview.vim",
		config = function()
			vim.fn["popup_preview#enable"]()
		end,
	},

	-- snipets
	{ "hrsh7th/vim-vsnip" },

	-- SKK
	{
		"vim-skk/denops-skkeleton.vim",
		dependencies = { "vim-denops/denops.vim" },
		config = function()
			vim.api.nvim_set_keymap("i", "<C-j>", "<Plug>(skkeleton-toggle)", { noremap=true, silent=true })
			vim.api.nvim_set_keymap("c", "<C-j>", "<Plug>(skkeleton-toggle)", { noremap=true, silent=true })
      vim.fn["skkeleton#config"]({
        globalDictionaries = {"~/.config/nvim/SKK-JISYO.L"},
        eggLikeNewline = true,
      })
--			vim.api.nvim_exec(
--				[[
--    call skkeleton#config({
--      \  'globalDictionaries': expand('~/.config/nvim/SKK-JISYO.L'),
--      \  'eggLikeNewline': v:true,
--      \ })
--      \]],
--				false
--			)
			local prev_buffer_config
			function _G.skkeleton_enable_pre()
				prev_buffer_config = vim.fn["ddc#custom#get_buffer"]()
				vim.fn["ddc#custom#patch_buffer"]({
					completionMenu = "native",
					sources = { "skkeleron" },
				})
			end
			function _G.skkeleton_disable_pre()
				vim.fn["ddc#custom#set_buffer"](prev_buffer_config)
			end
			vim.cmd([[
      augroup skkeleton_callbacks
        autocmd!
        autocmd User skkeleton_enable_pre call v:lua.skkeleton_enable_pre()
        autocmd User skkeleton_disable_pre call v:lua.skkeleton_disable_pre()
      augroup END
    ]])
		end,
	},
	{
		"delphinus/skkeleton_indicator.nvim",
		config = function()
			require("skkeleton_indicator").setup()
		end,
	},


--------------------------------------------------
	-- ddu
	{
		"Shougo/ddu.vim",
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
        -- most recentry file
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

       -- converter
       "uga-rosa/ddu-filter-converter_devicon",

       -- kind
       "Shougo/ddu-kind-file"
    },
    config = function()
      local lines = vim.opt.lines:get()
      local height, row = math.floor(lines * 0.8), math.floor(lines * 0.1)
      local columns = vim.opt.columns:get()
      local width, col = math.floor(columns * 0.8), math.floor(columns * 0.1)
--------------------------------------------------
-- ddu ff (default)
--------------------------------------------------
      vim.fn["ddu#custom#patch_global"]({
        ui = "ff",
        uiParams = {
          ff = {
            --startAutoAction = true,
            --autoAction = {
            --  delay = 0,
            --  name = "preview",
            --},
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
            --previewRow= 1,
            --previewCol= '&columns / 2 + 1',
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

--------------------------------------------------
-- ddu buffer
--------------------------------------------------
      vim.fn["ddu#custom#patch_local"]("buffer", {
        sources = {
          {name = "buffer"}
        },
        uiParams = {
          ff = {startFilter = false},
        },
      })

--------------------------------------------------
-- ddu grep
--------------------------------------------------
      vim.fn["ddu#custom#patch_local"]("grep", {
        sourceParams = {
          rg = {
            args = {"--column", "--no-heading", "--color", "never"},
          },
        },
        uiParams = {
          ff = {startFilter = false},
        },
      })

--------------------------------------------------
-- ddu grep_root
--------------------------------------------------
      vim.fn["ddu#custom#patch_local"]("grep_root", {
        sources = {
          { name = "file_rec" },
        },
        sourceOptions = {
          file_rec = {
            path = vim.fn.expand("~")
          },
        },
        sourceParams = {
          rg = {
            args = {"--column", "--no-heading", "--color", "never"},
          },
        },
        uiParams = {
          ff = {startFilter = false},
        },
      })

--------------------------------------------------
-- ddu help-ff
--------------------------------------------------
      vim.fn["ddu#custom#patch_local"]("help-ff", {
        --uiParams = {
        --  ff = {
        --    split = "vertical",
        --    splitDirection = "topleft",
        --    startFilter = true,
        --  },
        --},
        sources = {
          { name = "help" },
        },
        sourceOptions = {
          help = {
            defaultAction = "open",
          },
        },
      })

--------------------------------------------------
-- ddu ff keymaps
--------------------------------------------------

      -- normal mode

			local ddu_ff_keymap = vim.api.nvim_create_augroup("ddu_ff_keymap", { clear = true })
      vim.api.nvim_create_autocmd("filetype", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff",
        callback = function()
          local opts = { noremap = true, silent = true, buffer = true }
          vim.keymap.set({ "n" }, "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
          vim.keymap.set({ "n" }, "t", [[<Cmd>call ddu#ui#do_action("itemAction", {"name": "open", "params": {"command": "tabe",}})<CR>]], opts)
          vim.keymap.set({ "n" }, "s", [[<Cmd>call ddu#ui#do_action("itemAction", {"name": "open", "params": {"command": "split",}})<CR>]], opts)
          vim.keymap.set({ "n" }, "v", [[<Cmd>call ddu#ui#do_action("itemAction", {"name": "open", "params": {"command": "vsplit",}})<CR>]], opts)
          vim.keymap.set({ "n" }, "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
          vim.keymap.set({ "n" }, "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], opts)
          vim.keymap.set({ "n" }, "<Space>", [[<Cmd>call ddu#ui#do_action("toggleSelectItem")<CR>]], opts)
          vim.keymap.set({ "n" }, "p", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], opts)
          vim.keymap.set({ "n" }, "<C-c>", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
          vim.keymap.set({ "n" }, "<Esc>", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
          vim.keymap.set({ "n" }, "a", [[<Cmd>call ddu#ui#do_action("chooseAction")<CR>]], opts)
          vim.keymap.set({ "n" }, "<C-N>", [[<Cmd>call ddu#ui#do_action("cursorNext")<CR>]], opts)
          vim.keymap.set({ "n" }, "<C-P>", [[<Cmd>call ddu#ui#do_action("cursorPrevious")<CR>]], opts)
        end,
      })

      -- filtering mode
      vim.api.nvim_create_autocmd("FileType", {
        group = ddu_ff_keymap,
        pattern = "ddu-ff-filter",
        callback = function ()
          --local opts = { noremap = true, silent = true, buffer = true }
          local opts = { noremap = true, buffer = true }
          vim.keymap.set({ "n", "i" }, "<CR>", [[<Esc><Cmd>close<CR>]], opts)
          vim.keymap.set({ "n" }, "q", [[<Esc><Cmd>close<CR>]], opts)
          vim.keymap.set({ "n", "i" }, "<C-c>", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
          vim.keymap.set({ "n", "i" }, "<C-N>", [[<Cmd>call ddu#ui#do_action("cursorNext")<CR>]], opts)
          vim.keymap.set({ "n", "i" }, "<C-P>", [[<Cmd>call ddu#ui#do_action("cursorPrevious")<CR>]], opts)
        end,
      })

--------------------------------------------------
-- ddu action_select
--------------------------------------------------
      --vim.fn["ddu#custom#patch_local"]("action_select", {
      --  ui = "ui_select",
      --  sources = {
      --    {
      --      name = "actions",
      --      params = {},
      --    }
      --  },
      --  sourceOptions = {
      --    _ = {
      --      columns = {"filename"},
      --    },
      --  },
      --  --kindOptions = {
      --  --  file = {
      --  --    defaultAction = "open",
      --  --  },
      --  --},
      --})


--------------------------------------------------
-- ddu filer
--------------------------------------------------
      vim.fn["ddu#custom#patch_local"]("filer", {
        ui = "filer",
        uiParams = {
          filer = {
            winWidth = 40,
            split = "vertical",
            splitDirection = "topleft",
          },
        },
        sources = {
          {
            name = "file",
            params = {},
          }
        },
        sourceOptions = {
          _ = {
            columns = {"filename"},
          },
        },
        kindOptions = {
          ui_select = {
            defaultAction = "select",
          },
        },
        resume = true,
      })

--------------------------------------------------
-- ddu filer keymaps
--------------------------------------------------

			local ddu_filer_keymap = vim.api.nvim_create_augroup("ddu_filer_keymap", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = ddu_filer_keymap,
        pattern = "ddu-filer",
        callback = function()
            local opts = { noremap = true, silent = true, buffer = true }
            vim.keymap.set({ "n" }, "<CR>",
              [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], opts)
            vim.keymap.set({ "n" }, "<Space>",
              [[<Cmd>call ddu#ui#do_action("toggleSelectItem")<CR>]], opts)
            vim.keymap.set({ "n" }, "o",
              [[<Cmd>call ddu#ui#do_action("expandItem", {"mode": "toggle"})<CR>]],
            { buffer = true, noremap =true })
            vim.keymap.set({ "n" }, "q",
              [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
            vim.keymap.set({ "n" }, "<C-C>",
              [[<Cmd>call ddu#ui#do_action("quit")<CR>]], opts)
            vim.keymap.set({ "n" }, "a",
              [[<Cmd>call ddu#ui#do_action("chooseAction")<CR>]], opts)
        end
      })

--------------------------------------------------
--------------------------------------------------

-- ff
      -- file (default)
      vim.api.nvim_set_keymap("n", "<Space>uf", [[<Cmd>call ddu#start({})<CR>]], { noremap=true, silent=true})
      -- buffer
      vim.api.nvim_set_keymap("n", "<Space>ub", "<Cmd>call ddu#start({'name': 'buffer'})<CR>", { noremap=true, silent=true})
      --keymap("n", "<Space>ub", "<Cmd>call ddu#start({" ..
      --"'sources': [{'name': 'buffer'}], " ..
      --"})<CR>", { noremap=true, silent=true})
      -- grep
      vim.api.nvim_set_keymap("n", "<Space>ug", "<Cmd>call ddu#start({" ..
      "'name': 'grep', " ..
      "'sources': [{'name': 'rg', 'params': {'input': expand('<cword>')}}]" ..
      "})<CR>", { noremap=true, silent=true})
      -- grep_root
      vim.api.nvim_set_keymap("n", "<Space>uG", "<Cmd>call ddu#start({" ..
      "'name': 'grep_root', " ..
      "'sources': [{'name': 'file_rec'}]" ..
      "})<CR>", { noremap=true, silent=true})
      -- help-ff
      vim.api.nvim_set_keymap("n", "<Space>uh", "<Cmd>call ddu#start({" ..
      "'name': 'help-ff', " ..
      "})<CR>", { noremap=true, silent=true})
      vim.api.nvim_create_user_command("Help", function()
        vim.fn["ddu#start"]({name = "help-ff"})
      end, {})

-- filer
      vim.api.nvim_set_keymap("n", "<Space>ue", "<Cmd>call ddu#start({" ..
        "'name':'filer'," ..
        "'searchPath':expand('%:p')" ..
      "})<CR>", { noremap=true, silent=true})

    end
	},
  --ddu end

--------------------------------------------------
	-- fzf
	{ "junegunn/fzf", build = "./install --all" },
	"junegunn/fzf.vim",

	-- display key bindeings
	{
		"folke/which-key.nvim",
		lazy = true,
		cmd = {
			"WhichKey",
		},
		opts = {},
	},

--------------------------------------------------
	-- DAP 使用する際に覚える
	"mfussenegger/nvim-dap",
	"rcarriga/nvim-dap-ui",
	-- pip install debugpy が必要
	{
		"mfussenegger/nvim-dap-python",
		lazy = true,
		ft = "python",
		config = function()
			local venv = os.getenv("VIRTUAL_ENV")
			command = string.format("%s/bin/python", venv)
			require("dap-python").setup(command)
		end,
	},

--------------------------------------------------
	-- easy motion
	{
		"easymotion/vim-easymotion",
		config = function()
			vim.api.nvim_set_keymap("n", "<Space><Space>", "<Plug>(easymotion-prefix)", { noremap=true, silent=true})
			--vim.g["EasyMotion_do_mapping"] = 0
			vim.api.nvim_set_keymap("n", "S", "<Plug>(easymotion-overwin-f2)", { noremap=true, silent=true})
			vim.g["EasyMotion_do_mapping_smartcase"] = 1
		end,
	},

--------------------------------------------------
	-- linter
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {

				python = { "flake8", "mypy" },
				markdown = { "markdownlint" },
				-- ~/.luacheckrcを作成してvim undefined errorを無視している
				lua = { "LuaCheck" },
			}

			local nvim_lint = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = nvim_lint,
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

--------------------------------------------------
	-- formatter
	{
		"mhartington/formatter.nvim",
		config = function()
			-- Utilities for creating configurations
			local util = require("formatter.util")
			-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
			require("formatter").setup({
				-- Enable or disable logging
				logging = true,
				-- Set the log level
				log_level = vim.log.levels.WARN,
				-- All formatter configurations are opt-in
				filetype = {
					-- Formatter configurations for filetype "lua" go here
					-- and will be executed in order
					lua = {
						-- "formatter.filetypes.lua" defines default configurations for the
						-- "lua" filetype
						require("formatter.filetypes.lua").stylua,
						-- You can also define your own configuration
						function()
							-- Full specification of configurations is down below and in Vim help
							-- files
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"--",
									"-",
								},
								stdin = true,
							}
						end,
					},
					python = {
						-- black
						function()
							return {
								exe = "black",
								args = { "-q", "-" },
								stdin = true,
							}
						end,
						-- isort
						function()
							return {
								exe = "isort",
								args = { "--stdout", "--profile", "black", "-" },
								stdin = true,
							}
						end,
					},
					rust = {
						-- rustfmt
						function()
							return {
								exe = "rustfmt",
								args = { "--emit=stdout" },
								stdin = true,
							}
						end,
					},
					markdown = {
						-- markdownlint
						function()
							return {
								exe = "markdownlint",
								args = { "--stdin" },
								stdin = true,
							}
						end,
					},
					-- Use the special "*" filetype for defining formatter configurations on
					-- any filetype
					["*"] = {
						-- "formatter.filetypes.any" defines default configurations for any
						-- filetype
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})
		end,
	},

--------------------------------------------------
	-- terminal
	{ "kassio/neoterm", lazy = true },

	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			vim.cmd("silent TSUpdate")
		end,
	},

--------------------------------------------------
	-- 編集拡張系
	{ "cohama/lexima.vim" },
	{ "tpope/vim-surround" },
	{ "tpope/vim-commentary" },

------------------------------------------------------------------------------

}
