vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-context" })

require 'treesitter-context'.setup({
  max_lines = 15,
  multiline_threshold = 1,
  separator = '─',
})
