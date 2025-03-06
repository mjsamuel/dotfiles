return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          width = 0.8,
          height = 0.8,
        },
      })

      local packages = {
        -- lsp
        "bash-language-server",
        "css-lsp",
        "emmet-ls",
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
  }
}
