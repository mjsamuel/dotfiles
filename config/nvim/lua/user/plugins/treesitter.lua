vim.pack.add({ {
  src = "https://github.com/nvim-treesitter/nvim-treesitter",
  version = "main"
} })

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
  "yaml",
}
local alreadyInstalled = require("nvim-treesitter.config").get_installed()
local parsersToInstall = vim.iter(ensureInstalled)
    :filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
    :totable()
treesitter.install(parsersToInstall)

vim.filetype.add({ filename = { ["Caddyfile"] = "caddy" } })
vim.filetype.add({ pattern = { [".*%.tmpl%..*"] = "gotmpl" } })
vim.filetype.add({ pattern = { [".*/git/config"] = "gitconfig", [".*/git/ignore"] = "gitignore" } })
vim.filetype.add({ extension = { mdx = 'mdx' } })

vim.treesitter.language.register('markdown', 'mdx')
vim.treesitter.language.register('bash', 'zsh')

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
  desc = "Try to enable tree-sitter syntax highlighting",
  pattern = "*", -- run on *all* filetypes
  callback = function()
    pcall(function() vim.treesitter.start() end)
  end,
})
