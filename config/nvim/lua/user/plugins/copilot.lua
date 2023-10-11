local M = {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "VeryLazy",
  cond = function()
    return vim.fn.executable("node") == 1
  end,
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
    keymap = { accept = false },
  },
}

return M
