local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local km_opts = require("const.keymap")

local M = {}

function M.setup()
keymap.set("", "<Space>", "<Nop>", km_opts.ns)
keymap.set("n", "<Space>q", ":<C-U>qa<CR>", km_opts.ns)
keymap.set("n", "<Space><Space>q", ":<C-U>qa!<CR>", km_opts.ns)
-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Normal
--------------------------------------------------
-- winddow
--------------------------------------------------
keymap.set("n", "<Space>c", ":<C-u>clo<CR>", km_opts.ns)
keymap.set("n", "<Space>o", ":<C-u>only<CR>", km_opts.ns)

--------------------------------------------------
-- cursor move
--------------------------------------------------
keymap.set("n", "j", "gj", { noremap = true })
keymap.set("n", "k", "gk", { noremap = true })

--------------------------------------------------
-- tab
--------------------------------------------------
keymap.set("n", "<C-T>t", ":$tabnew<cr>", km_opts.ns)
keymap.set("n", "<C-T>c", ":tabclose<CR>", km_opts.ns)
keymap.set("n", "<C-T>o", ":tabonly<CR>", km_opts.ns)
keymap.set("n", "<C-T>n", ":tabn<CR>", km_opts.ns)
keymap.set("n", "<C-T>p", ":tabp<CR>", km_opts.ns)

--------------------------------------------------
-- args
--------------------------------------------------
keymap.set("n", "<C-N>", ":next<CR>", km_opts.ns)
keymap.set("n", "<C-P>", ":previous<CR>", km_opts.ns)

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

-- g/でハイライトやめる
keymap.set("n", "g/", ":<C-u>noh<Return>", km_opts.ns)

---- fzf
--keymap.set("n", "<Space>ff", ":<C-u>Files<CR>", km_opts.ns)
--keymap.set("n", "<Space>fb", ":<C-u>Buffers<CR>", km_opts.ns)
--keymap.set("n", "<Space>fc", ":<C-u>Commands<CR>", km_opts.ns)
--keymap.set("n", "<Space>fh", ":<C-u>History<CR>", km_opts.ns)
--keymap.set("n", "<Space>fm", ":<C-u>Maps<CR>", km_opts.ns)
--keymap.set("n", "<Space>f/", ":<C-u>History/<CR>", km_opts.ns)
--keymap.set("n", "<Space>f:", ":<C-u>History:<CR>", km_opts.ns)
--keymap.set("n", "<Space>fr", ":<C-u>Rg<CR>", km_opts.ns)
--keymap.set("n", "<Space>fl", ":<C-u>Lines<CR>", km_opts.ns)
--keymap.set("n", "<Space>fL", ":<C-u>BLines<CR>", km_opts.ns)
--keymap.set("n", "<Space>fH", ":<C-u>Helptags<CR>", km_opts.ns)

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

----------------------------------------------------------------------------------------------------
-- ddu mapping -------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
keymap.set("n", "<Space>b",":call ddu#start({'name': 'buffer'})<CR>", km_opts.ns)
keymap.set("n", "<Space>h",":call ddu#start({'name': 'help'})<CR>", km_opts.ns)
keymap.set("n", "<Space>g",":call ddu#start({'name': 'project_grep'})<CR>", km_opts.ns)
keymap.set("n", "<Space>f",":call ddu#start({'name': 'project'})<CR>", km_opts.ns)
keymap.set("n", "<Space>e",":call ddu#start({'name': 'filer'})<CR>", km_opts.ns)
----------------------------------------------------------------------------------------------------
-- /ddu mapping ------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- Command Mode用 --
keymap.set("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", { noremap = true, silent = true, expr = true })

-- dap keymap
keymap.set("n", "<F5>", ":DapContinue<CR>", { silent = true })
keymap.set("n", "<F10>", ":DapStepOver<CR>", { silent = true })
keymap.set("n", "<F11>", ":DapStepInto<CR>", { silent = true })
keymap.set("n", "<F12>", ":DapStepOut<CR>", { silent = true })
keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { silent = true })
keymap.set( "n", "<leader>dB",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>',
	{ silent = true }
)
keymap.set(
	"n",
	"<leader>lp",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
	{ silent = true }
)
keymap.set("n", "<leader>dr", ':lua require("dap").repl.open()<CR>', { silent = true })
keymap.set("n", "<leader>dl", ':lua require("dap").run_last()<CR>', { silent = true })
end

return M
