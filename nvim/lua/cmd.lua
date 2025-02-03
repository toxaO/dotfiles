local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local create_cmd = vim.api.nvim_create_user_command

local M = {}

function M.setup()
	create_cmd("ToggleQuickFix", function()
		if fn.empty(fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1 then
			cmd([[copen]])
		else
			cmd([[cclose]])
		end
	end, {})

  create_cmd("DebugMode", function()
    if g.is_enable_my_debug == 1 then
      g.is_enable_my_debug = 0
    else
      g.is_enable_my_debug = 1
    end
  end, {})

end

return M
