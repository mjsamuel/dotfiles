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

      local tools = {
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
        -- linters
        "cspell",
        -- formatters
        "black",
        "prettierd",
        "shfmt",
        "sql-formatter",
        "stylua",
      }

      local mr = require("mason-registry")
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "mason.nvim",
    opts = {},
  },
}
