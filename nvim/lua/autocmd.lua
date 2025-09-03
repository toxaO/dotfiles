local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local myutils = require("utils")

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
  -- adjust scroll off
  --------------------------------------------------------------------------------
  autocmd("WinScrolled", {
    group = my_augroup,
    pattern = "*",
    callback = function()
      local lines = fn["winheight"](0)
      local scrolloff = math.floor(lines / 7)
      vim.opt["scrolloff"] = scrolloff

      local width = fn["winwidth"](0)
      local sidescrolloff = math.floor(width / 25)
      vim.opt["sidescrolloff"] = sidescrolloff
    end
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
  -- set project_root
  --------------------------------------------------------------------------------
  autocmd({ "DirChanged" , "BufEnter"}, {
    group = my_augroup,
    pattern = "*",
    callback = function()
      b.project_root = myutils.fs.get_project_root_current_buf()
    end
  })

  --------------------------------------------------------------------------------
  -- commandline window --
  -- 余計なものを消す --
  --------------------------------------------------------------------------------
  autocmd("CmdwinEnter", {
    group = my_augroup,
    pattern = {":", "/", "?", "="},
    callback = function()
      vim.cmd([[silent g/^qa\?!\?$/de]])
      vim.cmd([[silent g/^wq\?a\?!\?$/de]])
      vim.cmd([[silent g/^\d*$/de]])
      vim.cmd([[setlocal nonumber]])
      vim.cmd([[setlocal signcolumn=no]])
    end
  })

  --------------------------------------------------------------------------------
  -- quickfix window --
  --------------------------------------------------------------------------------
  autocmd("QuickFixCmdPost", {
    group = my_augroup,
    pattern = {"*grep*"},
    callback = function()
      vim.cmd([[cwindow]])
    end})

  --------------------------------------------------------------------------------
  -- set cursorline only in active window
  --------------------------------------------------------------------------------
  -- -- アクティブ窓だけ有効化（浮動ウィンドウは対象外）
  -- local function apply_active_only()
  --   local cur = vim.api.nvim_get_current_win()
  --   for _, win in ipairs(vim.api.nvim_list_wins()) do
  --     local cfg = vim.api.nvim_win_get_config(win)
  --     if cfg.relative == "" then  -- floating window はスキップ
  --       local active = (win == cur)
  --       pcall(vim.api.nvim_set_option_value, "cursorline",   active, { win = win })
  --       pcall(vim.api.nvim_set_option_value, "cursorcolumn", active, { win = win })
  --     end
  --   end
  -- end

  -- apply_active_only()

  -- -- ウィンドウ切替/生成/タブ移動/フォーカス変化ごとに再適用
  -- local grp = vim.api.nvim_create_augroup("OnlyActiveCursorLC", { clear = true })
  -- vim.api.nvim_create_autocmd(
  --   { "WinEnter", "WinLeave", "WinNew", "BufWinEnter", "TabEnter", "TabLeave", "FocusGained", "FocusLost" },
  --   { group = grp, callback = apply_active_only }
  -- )


local grp = vim.api.nvim_create_augroup("OnlyActiveCursorLC", { clear = true })

local function is_ignored(win)
  -- 浮動ウィンドウは対象外
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg and cfg.relative ~= "" then return true end

  local buf = vim.api.nvim_win_get_buf(win)
  local bt  = vim.bo[buf].buftype
  if bt == "prompt" or bt == "nofile" then return true end

  -- ddu 系やプロンプト系は対象外
  local ft  = vim.bo[buf].filetype
  if ft == "ddu-ff" or ft == "ddu-ff-filter" or ft == "ddu-filer"
     or ft == "TelescopePrompt" or ft == "denops" then
    return true
  end
  return false
end

local function apply_active_only()
  local cur = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not is_ignored(win) then
      local active = (win == cur)
      -- 変更が必要なときだけセット（無駄な再描画を避ける）
      if vim.api.nvim_get_option_value("cursorline", { win = win }) ~= active then
        vim.api.nvim_set_option_value("cursorline", active, { win = win })
      end
      if vim.api.nvim_get_option_value("cursorcolumn", { win = win }) ~= active then
        vim.api.nvim_set_option_value("cursorcolumn", active, { win = win })
      end
    end
  end
end

-- dduが内部でウィンドウを切り替えた直後に当てるため schedule で遅延
vim.api.nvim_create_autocmd(
  { "WinEnter", "WinLeave", "BufWinEnter", "TabEnter", "TabLeave", "VimResized" },
  { group = grp, callback = function() vim.schedule(apply_active_only) end }
)

-- 念のため：ddu系のFileTypeが来たら、そのウィンドウでは常にOFF
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "ddu-ff", "ddu-ff-filter", "ddu-filer" },
  callback = function(args)
    local w = vim.fn.bufwinid(args.buf)
    if w ~= -1 then
      vim.api.nvim_set_option_value("cursorline",   false, { win = w })
      vim.api.nvim_set_option_value("cursorcolumn", false, { win = w })
    end
  end,
})

----------------------------------------------------------------------------------------------------
end

return M
