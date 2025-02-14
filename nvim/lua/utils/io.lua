local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local M = {}

function M._echo(t, mes)
  vim.cmd("echo" .. t .. " '" .. mes .. "'")
end

function M.echo(mes)
  M._echo("", mes)
end
function M.echom(mes)
  M._echo("m", mes)
end

function M.echoerr(mes)
  M._echo("err", mes)
end

function M.echoe(mes)
  M._echo("err", mes)
end

-- function M.show_contents(mes, args, stack)
--   M.echom(mes)
--   local this_stack = stack or 0
--   local tabshift = string.rep("  ", this_stack)  -- インデント簡略化

--   if args then
--     if type(args) ~= "table" then
--       M.echom(tabshift .. " : " .. tostring(args))  -- tostring で安全に表示
--       return
--     end
--     -- pairs を使用してすべてのキーをループ
--     for k, v in pairs(args) do
--       if not (type(k) == "string" and k:match("^__")) then
--         if type(v) == "table" then
--           M.echom(tabshift .. k .. " : {")  -- テーブルの開始を表示
--           M.show_contents("", v, this_stack + 1) -- ネストされたテーブルの再帰呼び出し
--           M.echom(tabshift .. "}")  -- テーブルの閉じを表示
--         else
--           M.echom(tabshift .. k .. " : " .. tostring(v))
--         end
--       end
--     end
--   end
-- end

function M.show_contents(mes, args, stack)
  local output = {}  -- ここに出力内容を蓄積
  local function collect_output(mes, args, stack)
    table.insert(output, mes)
    local this_stack = stack or 0
    local tabshift = string.rep("  ", this_stack)

    if args then
      if type(args) ~= "table" then
        table.insert(output, tabshift .. " : " .. tostring(args))
        return
      end
      for k, v in pairs(args) do
        if not (type(k) == "string" and k:match("^__")) then
          if type(v) == "table" then
            table.insert(output, tabshift .. k .. " : {")
            collect_output("", v, this_stack + 1)
            table.insert(output, tabshift .. "}")
          else
            table.insert(output, tabshift .. k .. " : " .. tostring(v))
          end
        end
      end
    end
  end

  -- データ収集
  collect_output(mes, args, stack)

  -- フローティングウィンドウで表示
  M.open_floating_window(output)
end

-- フローティングウィンドウの作成
function M.open_floating_window(lines)
  local buf = vim.api.nvim_create_buf(false, true)  -- 一時バッファ作成 (non-listed, scratch)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)  -- 出力内容をバッファに書き込む

  -- ウィンドウのサイズと位置を決定
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    border = "rounded",
  }

  -- フローティングウィンドウを開く
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- 閉じるためのマッピング (例: "q" で閉じる)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end

function M.show_attribute(mes, args)
  if type(args) ~= "tabel" then
    M.echom(tostring(args))  -- tostring で安全に表示
    return
  end

  for k, v in pairs(args) do
    if not (type(k) == "string" and k:match("^__")) then
      if type(v) == "table" then
        M.echom(tabshift .. k .. " : {")  -- テーブルの開始を表示
        M.echom(tabshift .. "}")  -- テーブルの閉じを表示
      else
        M.echom(tabshift .. k .. " : " .. tostring(v))
      end
    end
  end
end

function M.debug_echo(mes, args, stack)
  if vim.g.is_enable_my_debug then  -- グローバル変数参照の修正
    M.show_contents(mes, args, stack)
  end
end

function M.begin_debug(mes)
  M.debug_echo("begin " .. mes)
end
function M.end_debug(mes)
  M.debug_echo("end " .. mes)
end

function M.keymap_set(t)
  local mode  = t.mode
  local lhs   = t.lhs
  local rhs   = t.rhs
  local opts  = t.opts

  if type(mode) ~= "table" then
    mode = { t.mode }
  end

  for _, m in ipairs(mode) do
    keymap.set(m, lhs, rhs, opts)
  end
end

function M.read_secrets(filename)
  if filename:endswith(".json") then
    return M.read_json(filename)
  end

  return nil
end

function M.feedkey(key, mode)
	api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

function M.read_json(filename)
  M.echo("read_json(): " .. filename)

  local path = vim.fn["expand"]("~/.config/" .. filename)
  M.echo("path: " .. path)

  local fp = io.open(path)

  M.echo("try")
  if not fp then
    return nil
  end

  M.echo("can read")
  local r = fp:read("*a")

  M.echo("r: " .. r)
  local json = fn["json_decode"](r)
  fp:close()

  return json
end

return M
