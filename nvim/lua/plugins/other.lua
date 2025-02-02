local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

	{ "vim-jp/vimdoc-ja"},

	{ "cocopon/iceberg.vim" },

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "ryanoasis/vim-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},
  {"tsuyoshicho/transparency.vim"},
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
	-- { "neovim/nvim-lspconfig"},
	-- {
	-- 	"williamboman/mason.nvim",
	-- 	config = function()
	-- 		require("mason").setup()
	-- 	end,
	-- },

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason").setup()

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
							set("n", "<Space>ll", '<cmd>lua vim.diagnostic.open_float({scope="line"})<CR>')
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
	-- DAP
	"mfussenegger/nvim-dap",
	{
    "rcarriga/nvim-dap-ui",
    dependencies = {"nvim-neotest/nvim-nio"},
    config = function()
      require("dapui").setup()
    end
  },
	-- pip install debugpy が必要
	{
		"mfussenegger/nvim-dap-python",
		lazy = true,
		ft = "python",
		config = function()
			local venv = os.getenv("VIRTUAL_ENV")
			local command = string.format("%s/bin/python", venv)
			require("dap-python").setup(command)
		end,
	},

--------------------------------------------------
  -- quick run
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
--------------------------------------------------

--------------------------------------------------
  -- python to test
  { "tpope/vim-dispatch" },
  { "radenling/vim-dispatch-neovim" },
  { "janko-m/vim-test",
    dependencies = "vim-dispatch",
    config = function ()
      g["test#strategy"] = "dispatch"
    end},
  { "aliev/vim-compiler-python",
    config = function()
      vim.env["PYTHONWARNINGS"] = "ignore"
      g["python_compiler_fixqflist"] = 1
    end},
--------------------------------------------------
--------------------------------------------------
	-- easy motion
	{
		"easymotion/vim-easymotion",
		config = function()
			vim.g["EasyMotion_do_mapping"] = 0
			vim.g["EasyMotion_smartcase"] = 1
		end,
	},

--------------------------------------------------
	-- linter
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
        -- c = { "clang-format" },
				python = { "flake8", "mypy" },
				markdown = { "markdownlint" },
				-- ~/.luacheckrcを作成してvim undefined errorを無視している
				lua = { "luacheck" },
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
	-- 編集拡張系
	{ "cohama/lexima.vim" },
	{ "tpope/vim-surround" },
	{ "tpope/vim-commentary" },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup()
    end
  },

--------------------------------------------------
  -- git
  {"lambdalisue/gin.vim"},

------------------------------------------------------------------------------

}
