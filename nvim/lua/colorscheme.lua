local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local M = {}

function M.setup()
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

-- floating window --
  vim.cmd("autocmd my_colorscheme ColorScheme * highlight FloatBorder ctermfg=109 guifg=#89b8c2")

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

end

return M
