local dap, dapui = require("dap"), require("dapui")

dap.configurations.java = {
	{
		type = "java",
		request = "attach",
		name = "Debug (Backend) - Remote",
		hostName = "127.0.0.1",
		port = 8787,
	},
	{
		type = "java",
		request = "attach",
		name = "Debug (Web) - Remote",
		hostName = "127.0.0.1",
		port = 8788,
	},
}
