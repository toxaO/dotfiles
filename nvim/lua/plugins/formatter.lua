local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

return {

	-- formatter
	{
		"mhartington/formatter.nvim",
		config = function()
			-- Utilities for creating configurations
			local util = require("formatter.util")
			-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
			require("formatter").setup({
				-- Enable or disable logging
				logging = true,
				-- Set the log level
				log_level = vim.log.levels.WARN,
				-- All formatter configurations are opt-in
				filetype = {
					-- Formatter configurations for filetype "lua" go here
					-- and will be executed in order
					lua = {
						-- "formatter.filetypes.lua" defines default configurations for the
						-- "lua" filetype
						require("formatter.filetypes.lua").stylua,
						-- You can also define your own configuration
						function()
							-- Full specification of configurations is down below and in Vim help
							-- files
							return {
								exe = "stylua",
								args = {
									"--search-parent-directories",
									"--stdin-filepath",
									util.escape_path(util.get_current_buffer_file_path()),
									"--",
									"-",
								},
								stdin = true,
							}
						end,
					},
					python = {
						-- black
						function()
							return {
								exe = "black",
								args = { "-q", "-" },
								stdin = true,
							}
						end,
						-- isort
						function()
							return {
								exe = "isort",
								args = { "--stdout", "--profile", "black", "-" },
								stdin = true,
							}
						end,
					},
					rust = {
						-- rustfmt
						function()
							return {
								exe = "rustfmt",
								args = { "--emit=stdout" },
								stdin = true,
							}
						end,
					},
					markdown = {
						-- markdownlint
						function()
							return {
								exe = "markdownlint",
								args = { "--stdin" },
								stdin = true,
							}
						end,
					},
					-- Use the special "*" filetype for defining formatter configurations on
					-- any filetype
					["*"] = {
						-- "formatter.filetypes.any" defines default configurations for any
						-- filetype
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})
		end,
	},

}
