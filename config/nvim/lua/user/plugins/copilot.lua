local M = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    cond = function() return vim.fn.executable("node") == 1 end,
    opts = {
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        keymap = { accept = false },
      },
    }
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = "zbirenbaum/copilot.lua",
    build = "make tiktoken",
    cmd = "CopilotChat",
    config = function()
      local prompts = {
        -- Code related prompts
        Explain = "Please explain how the following code works.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Tests = "Please explain how the selected code works, then generate unit tests for it.",
        Refactor = "Please refactor the following code to improve its clarity and readability.",
        FixCode = "Please fix the following code to make it work as intended.",
        FixError = "Please explain the error in the following text and provide a solution.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        -- Text related prompts
        Summarize = "Please summarize the following text.",
        Spelling = "Please correct any grammar and spelling errors in the following text.",
        Wording = "Please improve the grammar and wording of the following text.",
        Concise = "Please rewrite the following text to make it more concise.",
      }

      require("CopilotChat").setup({
        prompts = prompts,
        highlight_headers = false,
        separator = "",
        question_header = "#   You",
        answer_header = "##   Copilot",
        error_header = "###   Error",
        show_help = false,
        show_folds = false,
        auto_follow_cursor = true,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = 'copilot-*',
        callback = function()
          vim.cmd('RenderMarkdown enable')
          vim.opt_local.signcolumn = "no"
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end
      })
    end
  }
}

return M
