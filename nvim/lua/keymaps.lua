local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local km_opts = require("const.keymap")

-- keymap multi line example
--keymap.set("n", "<Space><Space>",
--  ":<C-U>echo 'line1'"
--  .."| echo 'line2'<CR>"
--, km_opts.ns)

local M = {}

function M.setup()
  keymap.set("", "<Space>", "<Nop>", km_opts.ns)
  -- keymap.set("n", "<Space><Space>",
  --   ":<C-U>echo 'single'"
  --   .."| echo 'daul'<CR>"
  -- , km_opts.ns)

  ----------------------------------------------------------------------
  -- Normal --
  ----------------------------------------------------------------------

  --------------------------------------------------
  -- quit
  --------------------------------------------------
  keymap.set("n", "<Space>q", ":<C-U>qa<CR>", km_opts.ns)
  keymap.set("n", "<Space>Q", ":<C-U>qa!<CR>", km_opts.ns)

  --------------------------------------------------
  -- window
  --------------------------------------------------
  keymap.set("n", "<Space>c", ":<C-u>clo<CR>", km_opts.ns)
  keymap.set("n", "<Space>o", ":<C-u>only<CR>", km_opts.ns)

  --------------------------------------------------
  -- session
  --------------------------------------------------
  keymap.set("n", "<Space>S", ":<C-u>mksession! | echo 'save Session!'<CR>", km_opts.ns)

  --------------------------------------------------
  -- messages
  --------------------------------------------------
  keymap.set("n", "<Space>M", ":<C-u>messages<CR>", km_opts.n)

  --------------------------------------------------
  -- easymotion
  --------------------------------------------------
	keymap.set("n", "s", "<Plug>(easymotion-overwin-f2)", km_opts.ns)

  --------------------------------------------------
  -- cursor move
  --------------------------------------------------
  keymap.set("n", "j", "gj", { noremap = true })
  keymap.set("n", "k", "gk", { noremap = true })

  --------------------------------------------------
  -- tab
  --------------------------------------------------
  keymap.set("n", "<C-T>t", ":$tab split<cr>", km_opts.ns)
  keymap.set("n", "<C-T><C-T>", ":$tab split<cr>", km_opts.ns)
  keymap.set("n", "<C-T>c", ":tabclose<CR>", km_opts.ns)
  keymap.set("n", "<C-T><C-C>", ":tabclose<CR>", km_opts.ns)
  keymap.set("n", "<C-T>o", ":tabonly<CR>", km_opts.ns)
  keymap.set("n", "<C-T><C-O>", ":tabonly<CR>", km_opts.ns)
  keymap.set("n", "<C-N>", ":tabn<CR>", km_opts.ns)
  keymap.set("n", "<C-P>", ":tabp<CR>", km_opts.ns)
  keymap.set("n", "<C-T><C-N>", ":tabm + <CR>", km_opts.n)
  keymap.set("n", "<C-T><C-P>", ":tabm - <CR>", km_opts.n)
  keymap.set("n", "<C-T><C-R>", ":<C-U>TabRename ", km_opts.n)
  keymap.set("n", "<C-T>r", ":<C-U>TabRename ", km_opts.n)

  --------------------------------------------------
  -- move maps
  --------------------------------------------------
  -- 引数リスト移動
  keymap.set("n", "[a", ":prev<CR>", km_opts.ns)
  keymap.set("n", "]a", ":next<CR>", km_opts.ns)

  -- バッファ移動
  keymap.set("n", "[b", ":bp<CR>", km_opts.ns)
  keymap.set("n", "]b", ":bn<CR>", km_opts.ns)

  -- move tab
  keymap.set("n", "[t", "gT", km_opts.ns)
  keymap.set("n", "]t", "gt", km_opts.ns)


  --------------------------------------------------
  -- utils
  --------------------------------------------------

  -- split line --
  keymap.set({"n"}, "S", "i<CR><ESC>l", km_opts.n)

  -- scroll --
  keymap.set({"n", "v"}, "<C-F>", "<C-E>", km_opts.ns)
  keymap.set({"n", "v"}, "<C-B>", "<C-Y>", km_opts.ns)
  -- keymap.set({"n", "v"}, "<C-U>", "<C-Y>", km_opts.ns)
  -- keymap.set({"n", "v"}, "<C-D>", "<C-E>", km_opts.ns)

  -- Select all
  keymap.set("n", "<C-a>", "gg<S-v>G", km_opts.ns)

  -- increment/ decrement
  keymap.set("n", "-", "<C-X>", km_opts.ns)
  keymap.set("n", "+", "<C-A>", km_opts.ns)

  -- Do not yank with x
  keymap.set("n", "x", '"_x', km_opts.ns)

  -- 行の端に行く
  keymap.set("", "H", "^", km_opts.ns)
  keymap.set("", "L", "$", km_opts.ns)

  -- 行末までのヤンクにする
  keymap.set("n", "Y", "y$", km_opts.ns)

  -- <Esc><Esc>でハイライトやめる
  keymap.set("n", "<Esc><Esc>", ":<C-u>noh<Return>", km_opts.ns)

  -- insert cursor move --
  keymap.set("i", "<C-F>", "<Right>", km_opts.ns)
  keymap.set("i", "<C-b>", "<Left>", km_opts.ns)

  -- 貼り付け
  keymap.set("i", "<C-r><C-r>", '<C-r>"', km_opts.ns)

  -- Visual --
  -- Stay in indent mode
  keymap.set("v", "<", "<gv", km_opts.ns)
  keymap.set("v", ">", ">gv", km_opts.ns)

  -- ビジュアルモード時vで行末まで選択
  keymap.set("v", "v", "$h", km_opts.ns)

  -- 0番レジスタを使いやすくした
  keymap.set("v", "<C-p>", '"0p', km_opts.ns)

  -- Command Mode用 --
  keymap.set("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", km_opts.en)

  -- python --
  keymap.set("n", "<F5>", ":<C-U>QuickRun python<CR>")

  -- QuickRun --
  keymap.set("n", "<F3>", ":<C-u>bw! quickrun://output<CR>", km_opts.ns)

  -- quickfix --
  keymap.set("n", "<F2>", ":ToggleQuickFix<CR>", km_opts.ns)

  -- format --
  keymap.set("n", "<Space>=", ":Format<CR>", km_opts.ns)

  -- dap keymap
  keymap.set("n", "<F6>", ":DapContinue<CR>", km_opts.s)
  keymap.set("n", "<F7>", ":DapStepOver<CR>", km_opts.s)
  keymap.set("n", "<F8>", ":DapStepInto<CR>", km_opts.s)
  keymap.set("n", "<F9>", ":DapStepOut<CR>", km_opts.s)
  keymap.set("n", "<Space>db", ":DapToggleBreakpoint<CR>", km_opts.s)
  keymap.set( "n", "<Space>dB",
  ':lua req,ire("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>',
  km_opts.s)
  keymap.set( "n", "<Space>lp",
  ':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
  km_opts.s)
  keymap.set("n", "<Space>dr", ':lua require("dap").repl.open()<CR>', km_opts.s)
  keymap.set("n", "<Space>dl", ':lua require("dap").run_last()<CR>', km_opts.s)
  keymap.set('n', '<Space>D', ':lua require("dapui").toggle()<CR>', km_opts.s)
end

return M
