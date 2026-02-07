vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
  picker = require("user.plugins.snacks.picker"),
  bigfile = {},
  quickfile = {},
  gitbrowse = {},
  explorer = {
    trash = true,
  },
})
