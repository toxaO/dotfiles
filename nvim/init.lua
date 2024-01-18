vim.scriptencoding = "utf-8"
vim.cmd("autocmd!")

require("keymaps").setup()
require("autocmd").setup()
require("options").setup()
require("util").setup()
require("plugins").setup()

-- autocmdの設定の後にする必要あり
require("colorscheme").setup()

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

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


