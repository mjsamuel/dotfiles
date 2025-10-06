local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  cmd = "LspInfo",
  dependencies = {
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      config = function()
        require("mason").setup({ ui = { backdrop = 100 } })

        local packages = {
          -- lsp
          "bash-language-server",
          "css-lsp",
          "emmet-ls",
          "eslint-lsp",
          "gopls",
          "html-lsp",
          "json-lsp",
          "lemminx",
          "lua-language-server",
          "marksman",
          "pyright",
          "tailwindcss-language-server",
          "typescript-language-server",
          -- formatters
          "black",
          "prettierd",
          "shfmt",
          "sqlfmt"
        }

        local mr = require("mason-registry")
        for _, name in ipairs(packages) do
          local package = mr.get_package(name)
          if not package:is_installed() then package:install() end
        end
      end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = "mason.nvim",
      opts = { automatic_enable = true }
    }
  },
}

function M.config()
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })

  -- lsp overrides for go html templates
  for _, ls in ipairs({ "html", "emmet_ls", "tailwindcss" }) do
    local filetypes = vim.lsp.config[ls].filetypes
    table.insert(filetypes, "gotmpl")
    vim.lsp.config(ls, { filetypes = filetypes })
  end
end

return M
