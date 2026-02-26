return {

	-- DAP
	"mfussenegger/nvim-dap",
	{
    "rcarriga/nvim-dap-ui",
    dependencies = {"nvim-neotest/nvim-nio"},
    config = function()
      require("dapui").setup()
    end
  },
	-- pip install debugpy が必要
	{
		"mfussenegger/nvim-dap-python",
		lazy = true,
		ft = "python",
		config = function()
			local venv = os.getenv("VIRTUAL_ENV")
			local command = string.format("%s/bin/python", venv)
			require("dap-python").setup(command)
		end,
	},

}
