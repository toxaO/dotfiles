return {
	{
		"nanozuki/tabby.nvim",
		config = function()
			vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

			local theme = {
				fill = "TabLineFill",
				-- Also you can do this:
				--fill = { fg='#f2e9de', bg='#907aa9', style='italic' },
				head = "TabLine",
				current_tab = "TabLineSel",
				--current_tab = { fg='#f1e8de', bg='#907aa9', style='italic' },
				tab = "TabLine",
				--current_win = { fg='#f2e9de', bg='#907aa9', style='italic' },
				current_win = "TabLineSel",
				win = "TabLine",
				tail = "TabLine",
			}
			require("tabby.tabline").set(function(line)
				return {
					{
						{ "  ", hl = theme.head },
						line.sep("", theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl_tab = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl_tab, theme.fill),
							tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep("", hl_tab, theme.fill),
							hl = hl_tab,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
						local hl_win = win.is_current() and theme.current_win or theme.win
						return {
							line.sep("", hl_win, theme.fill),
							win.is_current() and "" or "",
							win.buf_name(),
							line.sep("", hl_win, theme.fill),
							hl = hl_win,
							margin = " ",
						}
					end),
					{
						line.sep("", theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end)
		end,
	},

}
