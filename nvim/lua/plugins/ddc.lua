local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local myutils = require("utils")
local km_opts = require("const.keymap")

local ddc = require("plugins.config.ddc")

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

return{

  { "Shougo/ddc.vim",
    dependencies = {
      "vim-denops/denops.vim",
      "Shougo/pum.vim",

      -- ui --
      "Shougo/ddc-ui-pum" ,
      "Shougo/ddc-ui-native" ,
    },
    config = function ()
      ddc.setup()
    end
  },

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
        globalDictionaries = {fn["expand"]("~/.config/nvim/SKK-JISYO.L")},
        eggLikeNewline = true,
      })
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

}
