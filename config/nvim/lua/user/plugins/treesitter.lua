local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
}

function M.config()
  require("nvim-treesitter.configs").setup({
    modules = {},
    ignore_install = {},
    ensure_installed = { "go", "html", "java", "json", "lua", "make", "markdown", "python", "typescript", "gotmpl" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    context_commentstring = { enable = true },
  })
  vim.filetype.add({ pattern = { [".*zsh"] = "sh" } })
  vim.filetype.add({ pattern = { [".*%.tmpl%..*"] = "gotmpl" } })
end

return M
