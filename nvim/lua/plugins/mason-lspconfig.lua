
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
			require("mason").setup()

			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "rust_analyzer" },
			})

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					local highlight_variable = function(client, bufnr)
						if client.supports_method("textDocument/document_highlight") then
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

					local lsp_opts = {
						on_attach = function(client, bufnr)
							client.server_capabilities.documentFormattingProvider = false
							local set = vim.keymap.set
							set("n", "<Space>ld", "<cmd>lua vim.lsp.buf.definition()<CR>")
							set("n", "<Space>lD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
							set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
							set("n", "<Space>li", "<cmd>lua vim.lsp.buf.implementation()<CR>")
							set("n", "<Space>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
							set("n", "<Space>ln", "<cmd>lua vim.lsp.buf.rename()<CR>")
							set("n", "<Space>la", "<cmd>lua vim.lsp.buf.code_action()<CR>")
							set("n", "<Space>lr", "<cmd>lua vim.lsp.buf.references()<CR>")
							set("n", "<Space>ll", '<cmd>lua vim.diagnostic.open_float({scope="line"})<CR>')
							set("n", "<Space>ls", "<cmd>lua vim.diagnostic.open_float()<CR>")
							set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
							set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
							set("n", "<Space>lf", "<cmd>lua vim.lsp.buf.format()<CR>")
							highlight_variable(client, bufnr)
						end,
					}

					if server_name == "lua_ls" then
						lsp_opts.settings = {
							Lua = {
								diagnostics = { globals = { "vim" } },
							},
						}
					end

					require("lspconfig")[server_name].setup(lsp_opts)
				end,
			})
		end,
	}

}
