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

  ------------------------------
  -- /ff setting --
  ------------------------------
    -- buffer --
  ddu.patch_local("buffer",{
    sources = {{name = "buffer"}},
  }) -- /buffer --

    -- args --
  ddu.patch_local("args",{
    sources = {{name = "arglist"}},
  }) -- /args --

    -- file_rec (use file_external + fd) --
  ddu.patch_local("file_rec",{

    sources = {
      {name = "file_external"},
    },

    sourceParams = {

      file_external = ddu_action.build_file_external_params(),

    },

  }) -- /file_rec --

   -- project all file --
  ddu.patch_local("project", {

    sources = { {name = "file_external"}, },

    sourceOptions = {
--          file_rec = {path = fn["expand"](u.fs.get_project_root_current_buf())}
    },

    sourceParams = {

      file_external = ddu_action.build_file_external_params(),

    },

  }) -- /project all file --

  ddu.patch_local("git_files", {

    sources = { {name = "file_external"}, },

    sourceParams = {

      file_external = {
        cmd = {
          "git",
          "ls-files",
          "-co",
          "--exclude-standard",
        },
      },

    },

  }) -- /git files --

    -- project grep --
  ddu.patch_local("grep", {

    uiParams = {

      ff = {
        ignoreEmpty = false,
        autoResize = false,
      },

    },

    sources = {
      {name = "rg"},
    },

    sourceOptions = {

      rg = {
        converters = {},
        matchers = {},
        sorters = {},
        volatile = true,
      },

    },

    sourceParams = {

      rg = {
        args = ddu_action.build_rg_args(),
        globs = ddu_action.build_rg_globs(),
        --input = fn["expand"]("<cword>"),
      },

    },

  }) -- /project grep

    -- help --
  ddu.patch_local("help",{
    sources = {{name = "help",}},
    uiParams = {
      ff = {
        startFilter = true,
        startAutoAction = true,
        autoAction = {
          delay = 0,
          name = "preview",
        },
        previewFloating = true,
        previewSplit = "vertical",
      },
    },
    sourceParams = {
      help = {
        helpLang = "ja",
      },
    },
  }) -- /help --

  ddu.patch_local("recent_files", {
    sources = { { name = "mr" } },
    sourceParams = {
      mr = {
        kind = "mru",
      },
    },
  }) -- /recent files --

  ------------------------------
  -- /ff setting --
  ------------------------------

  ------------------------------
  -- ff starter
  ------------------------------
  keymap.set("n", "<Space>f", function()
    fn["ddu#start"](vim.g.ddu_ff_last_start_options or { name = "buffer" })
  end, km_opts.nsw)
  ------------------------------
  -- /ff starter
  ------------------------------

end

return M
