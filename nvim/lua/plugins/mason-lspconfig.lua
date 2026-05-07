
local utils = require("utils")

local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Mason はツールのインストール管理を行うだけで、
      -- 「いつ何を動かすか」は別プラグイン側の設定で決まる。
      require("mason").setup()

      -- LSP が返した診断は Neovim 標準の diagnostic に集約される。
      -- ここでは画面上の常時表示を減らし、必要時に確認する運用にしている。
      vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

      -- LSP の役割:
      -- - 補完候補
      -- - 定義ジャンプや参照検索
      -- - 型チェックや構文レベルの診断
      --
      -- 例:
      -- - pyright: Python の型チェックが主役
      -- - lua_ls: Lua / Neovim Lua の補完と診断
      -- - rust_analyzer: Rust の補完と診断
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "rust_analyzer" },
      })

      local highlight_variable = function(client, bufnr)
        if client.supports_method("textDocument/documentHighlight") then
          local lsp_document_highlight = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = lsp_document_highlight,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.document_highlight()
            end,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = lsp_document_highlight,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.clear_references()
            end,
          })
        end
      end

      local on_attach = function(client, bufnr)
        local ft = vim.bo[bufnr].filetype
        if (ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp")
          and vim.g.c_if0_dimming_enabled ~= 1 then
          pcall(vim.lsp.semantic_tokens.stop, bufnr, client.id)
        end

        -- 整形は formatter.nvim に寄せる。
        -- LSP 側にも format 機能を持つサーバーがあるが、
        -- 複数箇所から整形すると「どれが効いたのか」が分かりにくくなる。
        client.server_capabilities.documentFormattingProvider = false
        local set = vim.keymap.set
        local opts = { buffer = bufnr, silent = true }

        -- よく使うものだけに絞る。
        -- LSP のキーバインドは「その言語サーバーがつながっているバッファ」でのみ有効。
        -- K: カーソル上の名前の説明を見る
        set("n", "K", vim.lsp.buf.hover, opts)
        -- definition: この名前が「定義されている場所」へ飛ぶ
        set("n", "<Space>ld", vim.lsp.buf.definition, opts)
        -- signature help: 関数の引数一覧を見る
        set("n", "<Space>lh", vim.lsp.buf.signature_help, opts)
        -- code action: LSP が提案する修正候補を開く
        set("n", "<Space>la", vim.lsp.buf.code_action, opts)
        -- references: この名前が「使われている場所」を一覧表示する
        set("n", "<Space>lr", vim.lsp.buf.references, opts)
        -- rename: 同じシンボル名をまとめて変更する
        set("n", "<Space>ln", vim.lsp.buf.rename, opts)
        -- diagnostic: 現在行のエラーや警告の詳細を開く
        set("n", "<Space>ll", function()
          vim.diagnostic.open_float({ scope = "line" })
        end, opts)
        -- diagnostic 移動: 前後のエラーや警告へ移動する
        set("n", "[d", vim.diagnostic.goto_prev, opts)
        set("n", "]d", vim.diagnostic.goto_next, opts)
        highlight_variable(client, bufnr)
      end

      -- Mason でインストール済みのサーバーを取得して設定
      local servers = require("mason-lspconfig").get_installed_servers()

      for _, server_name in ipairs(servers) do
        local lsp_opts = { on_attach = on_attach }

        if server_name == "lua_ls" then
          local util = require("lspconfig.util")
          lsp_opts.settings = {
            Lua = {
              -- Neovim 設定では `vim` グローバルを使うので、
              -- それを未定義変数として怒られないようにする。
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          }
          lsp_opts.root_dir = function(fname)
            local root = util.root_pattern(
              ".luarc.json",
              ".luarc.jsonc",
              ".luacheckrc",
              ".stylua.toml",
              "stylua.toml",
              "selene.toml",
              "init.lua",
              ".git"
            )(fname)

            if root == vim.loop.os_homedir() then
              return util.path.dirname(fname)
            end
            return root or util.path.dirname(fname)
          end
        end

        -- LSP 設定は「言語ごとにサーバーをつなぐ」部分。
        -- ここでつないだ診断が、`:lua vim.diagnostic.open_float()` などで見える。
        vim.lsp.config(server_name, lsp_opts)
      end
    end,
  }
}
