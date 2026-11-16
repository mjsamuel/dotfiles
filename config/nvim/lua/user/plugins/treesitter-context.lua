vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-context" })

require 'treesitter-context'.setup({
  enable = false,
  multiwindow = true,
  max_lines = 15,
  separator = '─',
})
