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


--------------------------------------------------------------------------------
-- keymaps
--------------------------------------------------------------------------------
--------------------------------------------------
-- keymap alias
--local opts = { noremap = true, silent = true }
--local keymap = vim.api.nvim_set_keymap
--
--keymap("", "<Space>", "<Nop>", opts)
--keymap("n", "<Space>q", ":<C-U>qa<CR>", opts)
--keymap("n", "<Space><Space>q", ":<C-U>qa!<CR>", opts)
---- Modes
----   normal_mode = 'n',
----   insert_mode = 'i',
----   visual_mode = 'v',
----   visual_block_mode = 'x',
----   term_mode = 't',
----   command_mode = 'c',
---- keymap("", "", "", opts)
--
---- Normal
----------------------------------------------------
---- ウィンドウ設定
----------------------------------------------------
--keymap("n", "<Space>c", ":<C-u>clo<CR>", opts)
--keymap("n", "<Space>o", ":<C-u>only<CR>", opts)
--keymap("n", "<C-h>", "<C-w>h", opts)
----keymap("n", "<C-j>", "<C-w>j", opts)
----keymap("n", "<C-k>", "<C-w>k", opts)
--keymap("n", "<C-l>", "<C-w>l", opts)
--
----------------------------------------------------
---- move
----------------------------------------------------
--vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true })
--vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true })
--
----------------------------------------------------
---- タブ
----------------------------------------------------
--keymap("n", "<Space>ta", ":$tabnew<CR>", opts)
--keymap("n", "<Space>tc", ":tabclose<CR>", opts)
--keymap("n", "<Space>to", ":tabonly<CR>", opts)
--keymap("n", "<Space>tn", ":tabn<CR>", opts)
--keymap("n", "<Space>tp", ":tabp<CR>", opts)
--keymap("n", "<C-N>", ":bnext<CR>", opts)
--keymap("n", "<C-P>", ":bprevious<CR>", opts)
--keymap("n", "<Space>tmn", ":-tabmove<CR>", opts)
--keymap("n", "<Space>tmp", ":+tabmove<CR>", opts)
--
---- move tab
--keymap("n", "[t", "gT", opts)
--keymap("n", "]t", "gt", opts)
--
---- 引数リスト移動
--keymap("n", "[a", ":prev<CR>", opts)
--keymap("n", "]a", ":next<CR>", opts)
--
---- バッファ移動
--keymap("n", "[b", ":bp<CR>", opts)
--keymap("n", "]b", ":bn<CR>", opts)
--
---- Select all
--keymap("n", "<C-a>", "gg<S-v>G", opts)
--
---- increment/ decrement
--keymap("n", "-", "<C-X>", opts)
--keymap("n", "+", "<C-A>", opts)
--
---- Do not yank with x
--keymap("n", "x", '"_x', opts)
--
---- 行の端に行く
--keymap("", "H", "^", opts)
--keymap("", "L", "$", opts)
--
---- 行末までのヤンクにする
--keymap("n", "Y", "y$", opts)
--
---- ESC*2 でハイライトやめる
--keymap("n", "<Esc><Esc>", ":<C-u>noh<Return>", opts)
--keymap("n", "<C-[><C-[>", ":<C-u>noh<Return>", opts)
--
---- fzf
--keymap("n", "<Space>ff", ":<C-u>Files<CR>", opts)
--keymap("n", "<Space>fb", ":<C-u>Buffers<CR>", opts)
--keymap("n", "<Space>fc", ":<C-u>Commands<CR>", opts)
--keymap("n", "<Space>fh", ":<C-u>History<CR>", opts)
--keymap("n", "<Space>fm", ":<C-u>Maps<CR>", opts)
--keymap("n", "<Space>f/", ":<C-u>History/<CR>", opts)
--keymap("n", "<Space>f:", ":<C-u>History:<CR>", opts)
--keymap("n", "<Space>fr", ":<C-u>Rg<CR>", opts)
--keymap("n", "<Space>fl", ":<C-u>Lines<CR>", opts)
--keymap("n", "<Space>fL", ":<C-u>BLines<CR>", opts)
--keymap("n", "<Space>fH", ":<C-u>Helptags<CR>", opts)
--
---- Insert --
--
--keymap("i", "<C-F>", "<Right>", opts)
--keymap("i", "<C-b>", "<Left>", opts)
--
---- 貼り付け
--keymap("i", "<C-r><C-r>", '<C-r>"', opts)
--
---- Visual --
---- Stay in indent mode
--keymap("v", "<", "<gv", opts)
--keymap("v", ">", ">gv", opts)
--
---- ビジュアルモード時vで行末まで選択
--keymap("v", "v", "$h", opts)
--
---- 0番レジスタを使いやすくした
--keymap("v", "<C-p>", '"0p', opts)
--
---- Command --
--keymap("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", { noremap = true, silent = true, expr = true })
--
---- dap keymap
--vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", { silent = true })
--vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", { silent = true })
--vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", { silent = true })
--vim.api.nvim_set_keymap("n", "<F12>", ":DapStepOut<CR>", { silent = true })
--vim.api.nvim_set_keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { silent = true })
--vim.api.nvim_set_keymap( "n", "<leader>dB",
--	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>',
--	{ silent = true }
--)
--vim.api.nvim_set_keymap(
--	"n",
--	"<leader>lp",
--	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
--	{ silent = true }
--)
--vim.api.nvim_set_keymap("n", "<leader>dr", ':lua require("dap").repl.open()<CR>', { silent = true })
--vim.api.nvim_set_keymap("n", "<leader>dl", ':lua require("dap").run_last()<CR>', { silent = true })
