local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "VeryLazy",
  branch = "main",
}

function M.config()
  local treesitter = require("nvim-treesitter")

  local ensureInstalled = {
    "css",
    "go",
    "gotmpl",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "python",
    "typescript",
  }
  local alreadyInstalled = require("nvim-treesitter.config").get_installed()
  local parsersToInstall = vim.iter(ensureInstalled)
      :filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
      :totable()
  treesitter.install(parsersToInstall)

  vim.filetype.add({ pattern = { [".*zsh"] = "sh" } })
  vim.filetype.add({ pattern = { [".*%.tmpl%..*"] = "gotmpl" } })
  vim.filetype.add({ pattern = { [".*/git/config"] = "gitconfig" } })
  vim.filetype.add({ pattern = { [".*/git/ignore"] = "gitignore" } })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
    desc = "Try to enable tree-sitter syntax highlighting",
    pattern = "*", -- run on *all* filetypes
    callback = function()
      pcall(function() vim.treesitter.start() end)
    end,
  })
end

return M
