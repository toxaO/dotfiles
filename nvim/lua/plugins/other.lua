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

  -- ステータスバー
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "ryanoasis/vim-devicons" },
		config = function()
			require("lualine").setup({
        sections = {
          lualine_c = {
            {
              function()
                return "cwd: " .. fn.fnamemodify(fn.getcwd(-1, 0), ":~")
              end,
            },
            {
              function()
                local path = fn.expand("%:p")
                if path == "" then
                  return "[No Name]"
                end
                local cwd = fn.getcwd(-1, 0)
                local prefix = cwd .. "/"
                if path == cwd then
                  return "."
                end
                if path:sub(1, #prefix) == prefix then
                  return path:sub(#prefix + 1)
                end
                return fn.fnamemodify(path, ":~")
              end,
            },
          },
          lualine_x = { "encoding", "filetype" },
        },
      })
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
	-- { "junegunn/fzf", build = "./install --all" },
	-- "junegunn/fzf.vim",

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

  -- diff
  {"sindrets/diffview.nvim"},

}
