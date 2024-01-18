local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local M = {}

function M.setup()
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

end

return M
