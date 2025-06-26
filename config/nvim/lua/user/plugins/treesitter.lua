local M = {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  event = "BufReadPost",
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

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { '*' },
    callback = function()
      -- remove error = false when nvim 0.12+ is default
      if vim.treesitter.get_parser(nil, nil, { error = false }) then
        vim.treesitter.start()
      end
    end,
  })
end

return M
