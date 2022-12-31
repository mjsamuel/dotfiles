local M = {
	"mfussenegger/nvim-jdtls",
	ft = "java",
}

function M.config()
	local home = os.getenv("HOME")
	local project_name = vim.fn.fnamemodify(vim.api.nvim_exec("!git rev-parse --show-toplevel", true), ":t")
	local workspace_dir = home .. "/Developer/workspaces/" .. project_name:sub(1, -2)

	local config = {
		cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xms1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			home
				.. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
			"-configuration",
			home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
			"-data",
			workspace_dir,
		},
		root_dir = require("jdtls.setup").find_root({ ".git" }),
		settings = {
			java = {
				configuration = {
					runtimes = {
						{
							name = "JavaSE-11",
							path = "/usr/java/jdk-11.0.11+9/",
						},
					},
				},
			},
		},
		init_options = {
			bundles = {
				vim.fn.glob(
					home
						.. "/Developer/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
				),
			},
		},
		on_attach = {
			require("jdtls").setup_dap(),
		},
	}

	require("jdtls").start_or_attach(config)
	require("jdtls.setup").add_commands()
end

return M
