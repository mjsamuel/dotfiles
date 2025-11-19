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
          "yaml-language-server",
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
  },
}

function M.config()
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  vim.lsp.config("*", { capabilities = capabilities })

  -- override html related lsps to be enabled for go templates
  for _, ls in ipairs({ "html", "emmet_ls", "tailwindcss" }) do
    local filetypes = vim.lsp.config[ls].filetypes
    table.insert(filetypes, "gotmpl")
    vim.lsp.config(ls, { filetypes = filetypes })
  end

  -- enable all lsp servers installed via mason
  local installed_packages = require("mason-registry").get_installed_packages()
  local lsp_config_names = vim.iter(installed_packages):fold({}, function(acc, pack)
    table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
    return acc
  end)
  vim.lsp.enable(lsp_config_names)
end

return M
