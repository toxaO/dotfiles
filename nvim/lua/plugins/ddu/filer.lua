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
  local function build_filer_cd_cmd(show_files)
    local cmd = {
      "fd",
      ".",
      "--max-depth",
      "1",
      "--hidden",
      "--follow",
      "--exclude",
      ".git",
      "--type",
      "d",
    }
    if show_files then
      table.insert(cmd, "--type")
      table.insert(cmd, "f")
    end
    return cmd
  end

  ------------------------------
  -- filer setting --
  ------------------------------
  -- filer ui params --
  local filer_ui = {

    filer = {

      winWidth = 40,
      split = "vertical",
      splitDirection = "topleft",
      sort = "filename",
      sortTreesFirst = true,

      -- preview setting
      previewSplit = "vertical",
      previewFloatingTitle = "Preview",
      previewFloating= true,
      previewFloatingBorder = "rounded"

    }

  }

  local filer_sourceOptions = {

    ["_"] = {
      --columns = {"devicon_filename"},
      columns = {"icon_filename"},
      converters = {},
    },

  }

  local filer_columnParams = {

    icon_filename = {
      span = 2,
      padding = 2,
      iconWidth = 2,
      useLinkIcon = "grayout",
      sort = "filename",
      sortTreesFirst = true,
    },

  }

  local filer_actionOptions = {

      narrow = { quit = false, },
      cd = {quit = false},
      tab_cd = { quit = false },

  }

  ------------------------------
  -- defaultのとりまとめ
  ------------------------------
  local filer_setting = {

    ui = "filer",
    uiParams = filer_ui ,
    sources = { {name = "file"} },
    sourceOptions =  filer_sourceOptions ,
    sourceParams = {},
    columnParams = filer_columnParams,
    actionOptions = filer_actionOptions,
    resume = true,
    sync = false,

  }

  -- default.name = "filer" としてlocalに適用
  ddu.patch_local("filer", filer_setting)
  local filer_cd_ui = vim.deepcopy(filer_setting.uiParams)
  filer_cd_ui.filer.split = "floating"
  filer_cd_ui.filer.floatingBorder = "rounded"
  filer_cd_ui.filer.floatingTitle = " CD Filer "
  filer_cd_ui.filer.winRow = 1
  filer_cd_ui.filer.winCol = 2
  filer_cd_ui.filer.winHeight = "&lines - 4"
  filer_cd_ui.filer.winWidth = "&columns - 4"

  ddu.patch_local("filer_cd", {
    ui = filer_setting.ui,
    uiParams = filer_cd_ui,
    sources = { { name = "file_external" } },
    sourceOptions = filer_setting.sourceOptions,
    sourceParams = {
      file_external = {
        cmd = build_filer_cd_cmd(false),
      },
    },
    columnParams = filer_setting.columnParams,
    actionOptions = {
      narrow = { quit = false },
      tab_cd = { quit = true },
    },
    resume = false,
    sync = false,
  })
  ------------------------------
  -- /filer setting --
  ------------------------------

  ------------------------------
  -- filer starter --
  ------------------------------

  keymap.set("n", "<Space>e", function()
    local current_path = vim.t.ddu_ui_filer_main_path or fn["getcwd"](-1, 0)
    filer_setting.name = current_path
    filer_setting.sourceOptions.file = {path = current_path}
    fn["ddu#start"]( filer_setting )
    fn["ddu#ui#do_action"]("cursorNext") -- デフォルトのカーソル位置がファイルパスに被るため
  end, km_opts.nsw)

  keymap.set("n", "<Space>c", function()
    local current_path = vim.t.ddu_ui_filer_cd_path or fn["getcwd"](-1, 0)
    fn["ddu#start"]({
      name = "filer_cd",
      sourceOptions = {
        file_external = { path = current_path },
      },
      sourceParams = {
        file_external = {
          cmd = build_filer_cd_cmd(false),
        },
      },
    })
    vim.schedule(function()
      pcall(function()
        fn["ddu#ui#do_action"]("cursorNext")
      end)
    end)
  end, km_opts.nsw)

  -- グローバルなファイラを４つほど作ろうと思ったけど、現状タブ毎のファイラでいい気がするので保留
  -- 各タブで開いてから統合したいタブで分割してバッファから探したほうがいい気がする
  -- g.first_filer_path = ""
  -- keymap.set("n", "<Space>1", function()
  --   g.first_filer_path = g.first_filer_path or fn["getcwd"]() -- dduを開くと変数が設定される
  --   filer_setting.name = "filer_1"
  --   filer_setting.sourceOptions.file = {path = g.first_filer_path}
  --   fn["ddu#start"]( filer_setting )
  --   fn["ddu#ui#do_action"]("cursorNext") -- デフォルトのカーソル位置がファイルパスに被るため
  -- end, km_opts.nsw)

  ------------------------------
  -- /filer starter --
  ------------------------------

end

return M
