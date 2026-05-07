local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

  -- formatter
  {
    "mhartington/formatter.nvim",
    config = function()
      -- Utilities for creating configurations
      local util = require("formatter.util")
      local has = function(exe)
        return vim.fn.executable(exe) == 1
      end
      local filetype = {
        -- formatter の役割は「見た目をそろえること」だけ。
        -- エラー検出は linter / LSP に任せる。
        -- Use the special "*" filetype for defining formatter configurations on
        -- any filetype
        ["*"] = {
          -- "formatter.filetypes.any" defines default configurations for any
          -- filetype
          require("formatter.filetypes.any").remove_trailing_whitespace,
        },
      }

      -- formatter は「入っているものだけ」登録する。
      -- 未導入ツールを無条件に呼ぶと `command not found` になるため。
      if has("stylua") then
        filetype.lua = {
          function()
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
        }
      end

      if has("black") then
        filetype.python = {
          -- Python は整形だけに絞る。
          -- 型チェックは pyright、規約チェックは必要なら後から追加する。
          function()
            return {
              exe = "black",
              args = { "-q", "-" },
              stdin = true,
            }
          end,
        }
      end

      if has("rustfmt") then
        filetype.rust = {
          function()
            return {
              exe = "rustfmt",
              args = { "--emit=stdout" },
              stdin = true,
            }
          end,
        }
      end

      -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
      require("formatter").setup({
        -- Enable or disable logging
        logging = true,
        -- Set the log level
        log_level = vim.log.levels.WARN,
        -- All formatter configurations are opt-in
        filetype = filetype,
      })
    end,
  },

}
