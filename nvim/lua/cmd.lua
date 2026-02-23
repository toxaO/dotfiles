local g = vim.g
local b = vim.b
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local create_cmd = vim.api.nvim_create_user_command

local M = {}

local function is_c_like(bufnr)
  local ft = vim.bo[bufnr].filetype
  return ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp"
end

local function apply_if0_dimming(enabled)
  vim.g.c_if0_dimming_enabled = enabled and 1 or 0
  vim.g.c_no_if0 = enabled and 0 or 1

  if enabled then
    vim.cmd("highlight! link cCppOut Comment")
    vim.cmd("highlight! link cCppOut2 Comment")
    vim.cmd("highlight! link cCppSkip Comment")
  else
    vim.cmd("highlight! link cCppOut Normal")
    vim.cmd("highlight! link cCppOut2 Normal")
    vim.cmd("highlight! link cCppSkip Normal")
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and is_c_like(bufnr) then
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if enabled then
          pcall(vim.lsp.semantic_tokens.start, bufnr, client.id)
        else
          pcall(vim.lsp.semantic_tokens.stop, bufnr, client.id)
        end
      end
    end
  end
end

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

  create_cmd("If0Toggle", function()
    local enabled = vim.g.c_if0_dimming_enabled == 1
    apply_if0_dimming(not enabled)
    vim.notify("if0 dimming: " .. ((not enabled) and "ON" or "OFF"), vim.log.levels.INFO)
  end, {})

  create_cmd("If0On", function()
    apply_if0_dimming(true)
    vim.notify("if0 dimming: ON", vim.log.levels.INFO)
  end, {})

  create_cmd("If0Off", function()
    apply_if0_dimming(false)
    vim.notify("if0 dimming: OFF", vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "objc", "objcpp" },
    callback = function()
      apply_if0_dimming(vim.g.c_if0_dimming_enabled == 1)
    end,
  })

end

return M
