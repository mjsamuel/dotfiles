local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
}

function M.config()
  require("nvim-treesitter.configs").setup({
    ensure_install = { "lua", "typescript", "java", "json", "markdown", "make", "python", "html" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    context_commentstring = { enable = true },
  })
end

return M
