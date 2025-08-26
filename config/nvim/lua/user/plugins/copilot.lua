local M = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    cond = function() return vim.fn.executable("node") == 1 end,
    opts = {
      copilot_node_command = "fnm exec --using=lts-latest",
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        keymap = { accept = false },
      },
      server = { type = "binary", },
    }
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = "zbirenbaum/copilot.lua",
    build = "make tiktoken",
    cmd = { "CopilotChat", "CopilotChatModels" },
    config = function()
      require("CopilotChat").setup({
        model = "claude-sonnet-4",
        window = {
          width = 0.4
        },
        headers = {
          user = " " .. (vim.env.USER or "User"),
          assistant = ' Copilot',
          tool = ' Tool',
        },
        separator = "",
        show_help = false,
        show_folds = false,
        auto_follow_cursor = true,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = 'copilot-*',
        callback = function()
          vim.opt_local.signcolumn = "no"
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end
      })
    end
  }
}

return M
