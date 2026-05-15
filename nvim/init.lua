-- first config file

vim.scriptencoding = "utf-8"
vim.cmd("autocmd!")

local denops_server_addr = vim.env.DENOPS_SERVER_ADDR
if denops_server_addr ~= nil and denops_server_addr ~= "" then
  vim.g.denops_server_addr = denops_server_addr
end

-- preference path --
vim.g.my_home_preference_path = vim.fn.expand("~/.config/nvim")
--vim.g.my_initvim_path = vim.fn.expand()

-- degug_mode
vim.g.is_enable_my_debug = false
-- vim.g.is_enable_my_debug = true

require("cmd").setup()
require("keymaps").setup()
require("autocmd").setup()
require("options").setup()
require("plugin").setup()
require("colorscheme").setup()
