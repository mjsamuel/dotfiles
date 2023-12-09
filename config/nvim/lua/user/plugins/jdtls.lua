local M = {
  "mfussenegger/nvim-jdtls",
  ft = "java",
}

function M.config()
  local jdtls = require("jdtls")
  local jdtls_setup = require("jdtls.setup")

  local data_home = os.getenv("XDG_DATA_HOME")
  local project_root = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1])
  local workspace_dir = os.getenv("XDG_CACHE_HOME") .. "/java-workspaces/" .. string.gsub(project_root, "/", ".")

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-noverify",
      "-Xms1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-jar",
      data_home .. "/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.500.v20230717-2134.jar",
      "-configuration",
      data_home .. "/nvim/mason/packages/jdtls/config_linux",
      "-data",
      workspace_dir,
    },
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = "JavaSE-11",
              path = "/usr/java/jdk-11.0.15+10/",
            },
          },
        },
      },
    },
    init_options = {
      bundles = {
        vim.fn.glob(
          data_home .. "/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
          1
        ),
      },
      extendedClientCapabilities = {
        progressReportProvider = false,
      },
    },
    -- on_attach = {
    --   jdtls.setup_dap({ hotcodereplace = "auto" }),
    -- },
  }

  jdtls.start_or_attach(config)
  jdtls_setup.add_commands()
end

return M
