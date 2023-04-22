local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
}

function M.config()
  require("nvim-treesitter.configs").setup({
    ensure_install = { "lua", "typescript", "java", "json", "markdown", "make", "python", "html" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    context_commentstring = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  })
end

return M
