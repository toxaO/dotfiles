local g = vim.g
local fn = vim.fn
local api = vim.api
local keymap = vim.keymap

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

local M = {}

function M.setup()
keymap("", "<Space>", "<Nop>", opts)
keymap("n", "<Space>q", ":<C-U>qa<CR>", opts)
keymap("n", "<Space><Space>q", ":<C-U>qa!<CR>", opts)
-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',
-- keymap("", "", "", opts)

-- Normal
--------------------------------------------------
-- ウィンドウ設定
--------------------------------------------------
keymap("n", "<Space>c", ":<C-u>clo<CR>", opts)
keymap("n", "<Space>o", ":<C-u>only<CR>", opts)
keymap("n", "<C-h>", "<C-w>h", opts)
--keymap("n", "<C-j>", "<C-w>j", opts)
--keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

--------------------------------------------------
-- move
--------------------------------------------------
vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true })
vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true })

--------------------------------------------------
-- タブ
--------------------------------------------------
keymap("n", "<Space>ta", ":$tabnew<CR>", opts)
keymap("n", "<Space>tc", ":tabclose<CR>", opts)
keymap("n", "<Space>to", ":tabonly<CR>", opts)
keymap("n", "<Space>tn", ":tabn<CR>", opts)
keymap("n", "<Space>tp", ":tabp<CR>", opts)
keymap("n", "<C-N>", ":bnext<CR>", opts)
keymap("n", "<C-P>", ":bprevious<CR>", opts)
keymap("n", "<Space>tmn", ":-tabmove<CR>", opts)
keymap("n", "<Space>tmp", ":+tabmove<CR>", opts)

-- move tab
keymap("n", "[t", "gT", opts)
keymap("n", "]t", "gt", opts)

-- 引数リスト移動
keymap("n", "[a", ":prev<CR>", opts)
keymap("n", "]a", ":next<CR>", opts)

-- バッファ移動
keymap("n", "[b", ":bp<CR>", opts)
keymap("n", "]b", ":bn<CR>", opts)

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- increment/ decrement
keymap("n", "-", "<C-X>", opts)
keymap("n", "+", "<C-A>", opts)

-- Do not yank with x
keymap("n", "x", '"_x', opts)

-- 行の端に行く
keymap("", "H", "^", opts)
keymap("", "L", "$", opts)

-- 行末までのヤンクにする
keymap("n", "Y", "y$", opts)

-- ESC*2 でハイライトやめる
keymap("n", "<Esc><Esc>", ":<C-u>noh<Return>", opts)
keymap("n", "<C-[><C-[>", ":<C-u>noh<Return>", opts)

-- fzf
keymap("n", "<Space>ff", ":<C-u>Files<CR>", opts)
keymap("n", "<Space>fb", ":<C-u>Buffers<CR>", opts)
keymap("n", "<Space>fc", ":<C-u>Commands<CR>", opts)
keymap("n", "<Space>fh", ":<C-u>History<CR>", opts)
keymap("n", "<Space>fm", ":<C-u>Maps<CR>", opts)
keymap("n", "<Space>f/", ":<C-u>History/<CR>", opts)
keymap("n", "<Space>f:", ":<C-u>History:<CR>", opts)
keymap("n", "<Space>fr", ":<C-u>Rg<CR>", opts)
keymap("n", "<Space>fl", ":<C-u>Lines<CR>", opts)
keymap("n", "<Space>fL", ":<C-u>BLines<CR>", opts)
keymap("n", "<Space>fH", ":<C-u>Helptags<CR>", opts)

-- Insert --

keymap("i", "<C-F>", "<Right>", opts)
keymap("i", "<C-b>", "<Left>", opts)

-- 貼り付け
keymap("i", "<C-r><C-r>", '<C-r>"', opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ビジュアルモード時vで行末まで選択
keymap("v", "v", "$h", opts)

-- 0番レジスタを使いやすくした
keymap("v", "<C-p>", '"0p', opts)

-- Command --
keymap("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", { noremap = true, silent = true, expr = true })

-- dap keymap
vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":DapStepOut<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { silent = true })
vim.api.nvim_set_keymap( "n", "<leader>dB",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>',
	{ silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>lp",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
	{ silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>dr", ':lua require("dap").repl.open()<CR>', { silent = true })
vim.api.nvim_set_keymap("n", "<leader>dl", ':lua require("dap").run_last()<CR>', { silent = true })
end

return M
