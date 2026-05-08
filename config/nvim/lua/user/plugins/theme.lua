vim.pack.add({ {
  src = "https://github.com/rose-pine/neovim",
  name = "rose-pine",
} })

require("rose-pine").setup({
  disable_float_background = true,
  extend_background_behind_borders = false,
  highlight_groups = {
    TreesitterContext = { bg = "base" },
    TreesitterContextLineNumber = { fg = "text", bg = "base" }
  }
})
vim.cmd("colorscheme rose-pine")
