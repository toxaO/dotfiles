vim.scriptencoding = "utf-8"
vim.cmd("autocmd!")

-- preference path --
vim.g.my_home_preference_path = vim.fn.expand("~/.config/nvim")
--vim.g.my_initvim_path = vim.fn.expand()

require("cmd").setup()
require("keymaps").setup()
require("autocmd").setup()
require("options").setup()
require("plugins").setup()
-- autocmdとpluginsの設定の後にする必要あり。
-- そのうちpluginの
require("colorscheme").setup()
