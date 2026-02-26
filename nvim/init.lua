-- first config file

vim.scriptencoding = "utf-8"
vim.cmd("autocmd!")

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
