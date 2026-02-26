return {
	-- linter
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
        -- c = { "clang-format" },
				python = { "flake8", "mypy" },
				markdown = { "markdownlint" },
				-- ~/.luacheckrcを作成してvim undefined errorを無視している
				lua = { "luacheck" },
			}

			local nvim_lint = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = nvim_lint,
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

}
