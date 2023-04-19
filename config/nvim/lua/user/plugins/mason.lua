return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })

      local tools = {
        "autopep8",
        "bash-language-server",
        "cmake-language-server",
        "css-lsp",
        "dockerfile-language-server",
        "emmet-ls",
        "html-lsp",
        "java-debug-adapter",
        "jdtls",
        "json-lsp",
        "lemminx",
        "lua-language-server",
        "markdownlint",
        "marksman",
        "prettier",
        "prettierd",
        "pyright",
        "shellcheck",
        "shfmt",
        "sql-formatter",
        "stylua",
        "tailwindcss-language-server",
        "taplo", -- toml language server
        "typescript-language-server",
      }

      local mr = require("mason-registry")
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = true,
  },
}
