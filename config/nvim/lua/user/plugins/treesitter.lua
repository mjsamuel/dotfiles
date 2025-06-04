local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
  branch = "main",
}

function M.config()
  require('nvim-treesitter').install { "go", "html", "java", "json", "lua", "make", "markdown", "python", "typescript", "gotmpl" }
  vim.filetype.add({ pattern = { [".*zsh"] = "sh" } })
  vim.filetype.add({ pattern = { [".*%.tmpl%..*"] = "gotmpl" } })
  vim.filetype.add({ pattern = { [".*/git/config"] = "gitconfig" } })
  vim.filetype.add({ pattern = { [".*/git/ignore"] = "gitignore" } })
end

return M
