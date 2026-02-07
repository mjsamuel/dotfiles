vim.pack.add({ "https://github.com/zbirenbaum/copilot.lua" })

require("copilot").setup({
  copilot_node_command = "fnm exec --using=lts-latest",
  panel = { enabled = false },
  suggestion = {
    auto_trigger = true,
    keymap = { accept = false },
  },
  server = { type = "binary", },
})
