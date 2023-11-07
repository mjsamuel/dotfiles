return {
  {
    "mfussenegger/nvim-dap",
    config = function()
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

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "nvim-dap",
    config = function()
      require("dapui").setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = true,
        layouts = {
          {
            elements = {
              "scopes",
              "watches",
              "breakpoints",
              "repl",
            },
            size = 40,
            position = "right",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
        },
      })
    end,
  },
}
