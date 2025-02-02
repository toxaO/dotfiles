local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

  -- 日本語ヘルプ
	{ "vim-jp/vimdoc-ja"},

  -- カラースキーム
	{ "cocopon/iceberg.vim" },

  -- 背景透明化
  {"tsuyoshicho/transparency.vim"},

  -- 検索時のカーソルカラー変更
  {
    "adamheins/vim-highlight-match-under-cursor",
    config = function ()
      g.HighlightMatchUnderCursor_highlight_link_group = "CurSearch"
    end
  },

  -- ステータスバー
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "ryanoasis/vim-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},

  -- アイコン拡張
	{ "ryanoasis/vim-devicons" },
	{ "nvim-tree/nvim-web-devicons" },

  -- 画面サイズ変更
	{ "simeji/winresizer",
  lazy = true,
  cmd = { "WinResizerStartResize" },
  keys = { "<C-E>", mode = "n" } },

	-- fzf
	{ "junegunn/fzf", build = "./install --all" },
	"junegunn/fzf.vim",

	-- キーバインド表示
	{
		"folke/which-key.nvim",
		lazy = true,
		cmd = { "WhichKey", },
		opts = {},
	},

	-- easy motion
	{ "easymotion/vim-easymotion",
		config = function()
			vim.g["EasyMotion_do_mapping"] = 0
			vim.g["EasyMotion_smartcase"] = 1
		end, },

  -- 括弧の補完
	{ "cohama/lexima.vim" },

  -- 括弧関係の拡張
	{ "tpope/vim-surround" },

  -- コメント拡張
	{ "tpope/vim-commentary" },

  -- インデントレベルの可視化
  { "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = true, },

  -- git
  {"lambdalisue/gin.vim"},

}
