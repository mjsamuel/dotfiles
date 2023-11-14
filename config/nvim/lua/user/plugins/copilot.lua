local M = {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  cond = function() return vim.fn.executable("node") == 1 end,
}

M.opts = {
  panel = { enabled = false },
  suggestion = {
    auto_trigger = true,
    keymap = { accept = false },
  },
}

return M
