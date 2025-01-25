local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
}

function M.config()
  require("nvim-treesitter.configs").setup({
    ensure_install = { "go", "html", "java", "json", "lua", "make", "markdown", "python", "typescript", "pkl" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    context_commentstring = { enable = true },
  })
end

return M
