return {
	-- linter
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			local has_markdownlint = vim.fn.executable("markdownlint") == 1

			-- 最小構成:
			-- - 普段の診断は LSP を主役にする
			-- - LSP がない / 弱い言語だけ linter を追加する
			--
			-- 役割の違い:
			-- - LSP: 型や構文、定義ジャンプ、補完
			-- - linter: 規約や書き方のチェック
			--
			-- 型チェックの例:
			--   number のはずの値に string を渡していないか
			-- 規約チェックの例:
			--   行が長すぎないか、見出し記法が崩れていないか
			lint.linters_by_ft = {
			}
			if has_markdownlint then
				lint.linters_by_ft.markdown = { "markdownlint" }
			end

			local nvim_lint = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = nvim_lint,
				callback = function()
					-- 保存時に、その filetype に割り当てた linter だけを実行する。
					-- 複数登録すれば複数走るが、最小構成では重複を避けるため絞る。
					lint.try_lint()
				end,
			})
		end,
	},

}
