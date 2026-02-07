vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
require("gitsigns").setup({
  diff_opts = { vertical = false },
  preview_config = { border = 'rounded', },
})
