vim.scriptencoding = "utf-8"
vim.cmd("autocmd!")

require("keymaps").setup()
require("options").setup()
require("util").setup()
require("plugins").setup()

--------------------------------------------------------------------------------
-- autocmd
--------------------------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

--------------------------------------------------------------------------------
-- define augroup
--------------------------------------------------------------------------------
augroup("my_augroup", { clear = true })
augroup("my_colorscheme", { clear = true })

--------------------------------------------------------------------------------
-- Remove whitespace on save
--------------------------------------------------------------------------------
autocmd("BufWritePre", {
  group = my_augroup,
	pattern = "*",
	command = ":%s/\\s\\+$//e",
})

--------------------------------------------------------------------------------
-- Don't auto commenting new lines
--------------------------------------------------------------------------------
autocmd("BufEnter", {
  group = my_augroup,
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

--------------------------------------------------------------------------------
-- Restore cursor location when file is opened
--------------------------------------------------------------------------------
autocmd({ "BufReadPost" }, {
  group = my_augroup,
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all" (the five listed parsers should always be installed)
			ensure_installed = { "c", "lua", "vim", "vimdoc", "python", "rust" },

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
			-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

			highlight = {
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		})
	end,
})

--------------------------------------------------------------------------------
-- commandline window
--------------------------------------------------------------------------------
autocmd("CmdwinEnter", {
  group = my_augroup,
  pattern = {":", "/", "?", "="},
  callback = function()
    vim.cmd([[silent g/^qa\?!\?$/de]])
    vim.cmd([[silent g/^wq\?a\?!\?$/de]])
    vim.cmd([[setlocal nonumber]])
    vim.cmd([[setlocal signcolumn=no]])
  end
})

--------------------------------------------------------------------------------
-- ColorScheme
--------------------------------------------------------------------------------
-- カラースキームはtablineの後に設定しないとtablineが有効にならないっぽい（バグ？）
-- 現在はairlinのtablineを使用していないため気にしなくてよい
vim.cmd("autocmd my_colorscheme ColorScheme * highlight Normal ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight Visual ctermfg=234 ctermbg=242 guifg=#17171b guibg=#6b7089")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight NonText ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight LineNr ctermbg=none guifg=#515e97 guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight Folded ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight SignColumn ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight FoldColumn ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight DiagnosticSignError ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight DiagnosticSignWarn ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight DiagnosticSignInfo ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight DiagnosticSignHint ctermbg=none guibg=none")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight Number ctermfg=109 guifg=#84a0c6")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight lualine_c_normal ctermfg=109 guifg=#84a0c6")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight TabLine ctermfg=245 ctermbg=233 guifg=#686f9a guibg=#0f1117")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight TabLineFill ctermfg=233 ctermbg=233 guifg=#0f1117 guibg=#0f1117")
vim.cmd("autocmd my_colorscheme ColorScheme * highlight TabLineSel ctermfg=252 ctermbg=237 guifg=#9a9ca5 guibg=#2a3158")
vim.cmd(
	"autocmd my_colorscheme ColorScheme * highlight LspReferenceText "
		.. "cterm=underline ctermfg=159 ctermbg=23 gui=underline guifg=#b3c3cc guibg=#384851"
)
vim.cmd(
	"autocmd my_colorscheme ColorScheme * highlight LspReferenceRead "
		.. "cterm=underline ctermfg=159 ctermbg=23 gui=underline guifg=#b3c3cc guibg=#384851"
)
vim.cmd(
	"autocmd my_colorscheme ColorScheme * highlight LspReferenceWrite "
		.. "cterm=underline ctermfg=159 ctermbg=23 gui=underline guifg=#b3c3cc guibg=#384851"
)
vim.cmd("colorscheme iceberg")

--------------------------------------------------------------------------------
-- ddc
--------------------------------------------------------------------------------

vim.fn["ddc#custom#patch_global"]("ui", "pum")
vim.fn["ddc#custom#patch_global"]("autoCompleteEvents", {
	"InsertEnter",
	"TextChangedI",
	"TextChangedP",
	"CmdlineChanged",
	"CmdlineEnter",
	"TextChangedT",
})
vim.fn["ddc#custom#patch_global"]("sources", {
  "lsp",
	"around",
	--    'mocword',
	"skkeleton",
})
vim.fn["ddc#custom#patch_global"]("sourceOptions", {
	around = {
		mark = "[A]",
	},
	mocword = {
		mark = "[Moc]",
		maxItems = 10,
		isVolatile = true,
	},
	lsp = {
		mark = "[LSP]",
		forceCompletionPattern = { [[\.\w*|:\w*|->\w*]] },
		sorters = { "sorter_lsp-kind" },
		minAutoCompleteLength = 1,
		--keywordPattern = {[[\k+]]},
	},
	["skkeleton"] = {
		mark = "[SKK]",
		matchers = { "skkeleton" },
		sorters = {},
	},
	_ = {
		matchers = { "matcher_fuzzy" },
		sorters = { "sorter_fuzzy", "sorter_rank" },
		converters = { "converter_remove_overlap", "converter_fuzzy" },
		minAutoCompleteLength = 3,
	},
})

vim.fn["ddc#custom#patch_global"]("sourceParams", {
	["lsp"] = {
		snippetEngine = vim.fn["denops#callback#register"](function(body)
			vim.fn["vsnip#anonymous"](body)
		end),
		enableResolveItem = true,
		enableAdditionalTextEdit = true,
	},
})

augroup("ddc_keymap", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
  group = ddc_keymap,
	callback = function(ev)
		local opt = { noremap = true }
		vim.keymap.set(
			{ "i" },
			"<C-n>",
			[[(pum#visible() ? '' : ddc#map#manual_complete()) . pum#map#select_relative(+1)]],
			{ expr = true, noremap = false }
		)
		vim.keymap.set(
			{ "i" },
			"<C-p>",
			[[(pum#visible() ? '' : ddc#map#manual_complete()) . pum#map#select_relative(-1)]],
			{ expr = true, noremap = false }
		)
		vim.keymap.set({ "i" }, "<C-y>", [[<Cmd>call pum#map#confirm()<CR>]], opt)
		vim.keymap.set({ "i" }, "<C-e>", [[<Cmd>call pum#map#cancel()<CR>]], opt)
		vim.keymap.set({ "i" }, "<PageDown>", [[<Cmd>call pum#map#insert_relative_page(+1)<CR>]], opt)
		vim.keymap.set({ "i" }, "<PageUp>", [[<Cmd>call pum#map#insert_relative_page(-1)<CR>]], opt)
		vim.keymap.set({ "i" }, "<CR>", function()
			if vim.fn["pum#entered"]() then
				return "<Cmd>call pum#map#confirm()<CR>" or "<CR>"
			else
				return "<CR>"
			end
		end, { expr = true, noremap = false })
		vim.keymap.set({ "i" }, "<C-m>", function()
			if vim.fn["pum#visible"]() then
				return "<Cmd>call ddc#map#manual_complete()<CR>"
			else
				return "<C-m>"
			end
		end, { expr = true, noremap = false })
		vim.keymap.set({ "i", "s" }, "<C-l>", function()
			return vim.fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-l>"
		end, { expr = true, noremap = false })
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			return vim.fn["vsnip#jumpable"](1) == 1 and "<Plug>(vsnip-jump-next)" or "<Tab>"
		end, { expr = true, noremap = false })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			return vim.fn["vsnip#jumpable"](-1) == 1 and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
		end, { expr = true, noremap = false })
		vim.keymap.set({ "n", "s" }, "<s>", [[<Plug>(vsnip-select-text)]], { expr = true, noremap = false })
		vim.keymap.set({ "n", "s" }, "<S>", [[<Plug>(vsnip-cut-text)]], { expr = true, noremap = false })
	end,
})
vim.g.vsnip_filetypes = {}
vim.fn["ddc#enable_terminal_completion"]()
vim.fn["ddc#enable"]()
--------------------------------------------------------------------------------
-- ddc config end
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- pum option
--------------------------------------------------------------------------------
-- 書き方例
--vim.fn["pum#set_option"]({horizontal_menu = true})


