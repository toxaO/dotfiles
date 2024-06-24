local g = vim.g
local o = vim.o
local fn = vim.fn
local opt = vim.opt
local api = vim.api
local keymap = vim.keymap

local M = {}

function M.setup()
  local options = {
    encoding = "utf-8",
    fileencoding = "utf-8",

    title = true,

    backup = false,
    swapfile = false,
    undofile = true,
    writebackup = false,
    backupskip = { "/tmp/*", "/private/tmp/*" },

    ruler = true,
    visualbell = true, -- エラー音を画面表示に,
    helplang = "ja,en", -- ヘルプファイル日本語化
    clipboard = "unnamed", -- クリップボード連携
    cursorline = true,
    number = true,
    syntax = "on",
    relativenumber = false,
    numberwidth = 4,
    completeopt = { "menuone", "noselect" },
    conceallevel = 0,
    hlsearch = true,
    ignorecase = true,
    mouse = "a",
    pumheight = 10,
    showcmd = true,
    cmdheight = 2,
    wildmenu = true,
    laststatus = 3, -- global status line
    signcolumn = "yes", -- 数字行左側の表示領域を常に表示
    wrap = true, -- 画面領域ないの折り返し
    wrapscan = true, -- 検索画ファイル末尾まで進んだら、ファイル先頭から再び検索する。
    winblend = 20, -- 画面の透過度
    wildoptions = "pum", -- コマンドラインの補完表示の種類選択
    pumblend = 5, -- pumの透過度
    background = "dark",
    scrolloff = 8,
    sidescrolloff = 8,
    guifont = "monospace:h17",
    splitbelow = false, -- オンのとき、ウィンドウを横分割すると新しいウィンドウはカレントウィンドウの下に開かれる
    splitright = false, -- オンのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる

    matchpairs = "(:),{:},[:],<:>,「:」,【:】,『:』",

    list = true, -- <Tab>や<EOL>を表示する
    listchars = "tab:>-,trail:~,eol:↴", -- 基本設定ではtabはexpandtabのため表示されない
    hidden = true, -- 裏のbufferを表示する際に警告が出ない
    showmatch = true, -- 括弧入力時に対応する括弧を知らせる
    matchtime = 1, -- 'showmatch' で対応カッコを表示する時間。0.1秒単位
    showmode = false, -- 挿入モード、置換モードまたはビジュアルモードで最終行にメッセージを表示する。
    showtabline = 2, -- このオプションは、いつタブページのラベルを表示するかを指定する。
    smartcase = true, -- 検索パターンが大文字を含んでいたらオプション 'ignorecase' を上書きする。
    smartindent = true, -- 自動インデント
    autoindent = true,
    termguicolors = true,
    updatetime = 300, -- スワップファイルへ書き込まれるまでの無操作時間

    -- tab関連
    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    softtabstop = 2,

  }

  vim.opt.shortmess:append("c")

  for k, v in pairs(options) do
    vim.opt[k] = v
  end
end

return M
