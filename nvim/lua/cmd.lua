local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local create_cmd = vim.api.nvim_create_user_command

local M = {}

function M.setup()
	create_cmd("ToggleQuickFix", function()
		if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1 then
			vim.cmd([[copen]])
		else
			vim.cmd([[cclose]])
		end
	end, {})

  vim.cmd([[
    command! ModifyCSProjFile call ModifyCSProjFile()
    function! ModifyCSProjFile()
        call system("find . -maxdepth 2 -name \"*.csproj\" | xargs sed -i -e 's/C:/\\/mnt\\/c/g'")
        call system("find . -maxdepth 2 -name \"*.csproj\" | xargs sed -i -e 's/D:/\\/mnt\\/d/g'")
        if exists(':YcmCompleter')
            execute "YcmCompleter ReloadSolution"
        endif
    endfunction
    ]])
end

return M
