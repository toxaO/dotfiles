local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local opt = vim.opt

local ddu = require("plugins.ddu.ddu_util")
local ddu_action = require("plugins.ddu.action")
local ddu_autocmd = require("plugins.ddu.autocmd")
local ddu_default = require("plugins.ddu.default")
local u = require("utils")
local km_opts = require("const.keymap")

local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local M = {}

function M.setup()
    -- buffer --
  ddu.patch_local("buffer",{
    sources = {{name = "buffer"}},
  }) -- /buffer --

    -- args --
  ddu.patch_local("args",{
    sources = {{name = "arglist"}},
  }) -- /args --

    -- file_rec --
  ddu.patch_local("file_rec",{

    sources = {
      {name = "file_rec"},
    },

    sourceParams = {

      file_rec = {

        ignoredDirectories = {
          ".git",
          "node_modules",
          "vendor",
          ".next",
          ".venv",
          "__pycache__",
          ".mypy_cache",
          "out",
        },

      },

    },

  }) -- /file_rec --

   -- project all file --
  ddu.patch_local("project", {

    sources = { {name = "file_rec"}, },

    sourceOptions = {
--          file_rec = {path = fn["expand"](u.fs.get_project_root_current_buf())}
    },

    sourceParams = {

      file_rec = {

        ignoredDirectories = {
          ".git",
          "node_modules",
          "vendor",
          ".next",
          ".venv",
          "__pycache__",
          ".mypy_cache",
          "out",
        },

      },

    },

  }) -- /project all file --

    -- project grep --
  ddu.patch_local("project_grep", {

    uiParams = {

      ff = {
        ignoreEmpty = false,
        autoResize = false,
      },

    },

    sources = {
      --{name = "file_rec"},
      {name = "rg"},
    },

    sourceOptions = {

      file_rec = {
       -- path = u.fs.get_project_root_current_buf()
      },

      rg = {
        matchers = {},
        volatile = true,
      },

    },

    sourceParams = {

      rg = {
        args = {"--column", "--no-heading", "--color", "never"},
        --input = fn["expand"]("<cword>"),
      },

    },

  }) -- /project grep

    -- help --
  ddu.patch_local("help",{
    sources = {{name = "help",}},
    sourceParams = {
      helpLang = "ja",
    },
  }) -- /help --

  -- /ff setting --

end

return M
