local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "VeryLazy",
  lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  branch = "main",
}

function M.config()
  local treesitter = require("nvim-treesitter")

  local ensureInstalled = {
    "bash",
    "caddy",
    "css",
    "diff",
    "dockerfile",
    "go",
    "gotmpl",
    "html",
    "java",
    "javascript",
    "json",
    "jsx",
    "lua",
    "make",
    "markdown",
    "python",
    "tsx",
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
  vim.filetype.add({ pattern = { ["Caddyfile"] = "caddy" } })

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
