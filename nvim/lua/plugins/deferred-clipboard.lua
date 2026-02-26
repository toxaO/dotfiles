local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

return {
  'EtiamNullam/deferred-clipboard.nvim',
  event = 'VeryLazy', -- lz
  config = function()
    if vim.fn.has("wsl") then
      require('deferred-clipboard').setup {
        fallback = 'unnamedplus',
        lazy = true,
      }
      vim.g.clipboard = {
        name = 'clip',
        copy = {
          ['+'] = 'win32yank.exe -i --crlf',
          ['*'] = 'win32yank.exe -i --crlf',
        },
        paste = {
          ['+'] = 'win32yank.exe -o --lf',
          ['*'] = 'win32yank.exe -o --lf',
        },
        cache_enable = 0,
      }
    end
  end
}
