vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
  picker = require("user.plugins.snacks.picker"),
  statuscolumn = {},
  bigfile = {},
  quickfile = {},
  gitbrowse = {},
  explorer = {
    trash = true,
  },
})

vim.ui.select = require("snacks").picker.select --- override default ui.select with snacks picker
