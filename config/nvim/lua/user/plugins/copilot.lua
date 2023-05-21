local M = {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "VeryLazy",
}

M.opts = {
  panel = {
    enabled = true,
    auto_refresh = true,
    layout = {
      position = "right",
      ratio = 0.4,
    },
  },
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<M-Enter>",
      prev = "<M-[>",
      next = "<M-]>",
      dismiss = "<M-Esc>",
    },
  },
}

return M
