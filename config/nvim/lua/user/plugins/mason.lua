return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup({
        ui = {
          border = require("user.misc.opts").border,
        },
      })

      local tools = {
        "angular-language-server",
        "autopep8",
        "bash-language-server",
        "cmake-language-server",
        "css-lsp",
        "dockerfile-language-server",
        "emmet-ls",
        "html-lsp",
        "jdtls",
        "json-lsp",
        "lemminx",
        "lua-language-server",
        "markdownlint",
        "marksman",
        "prettier",
        "prettier",
        "pyright",
        "shellcheck",
        "shfmt",
        "sql-formatter",
        "sqlls",
        "stylua",
        "stylua",
        "tailwindcss-language-server",
        "taplo",
        "typescript-language-server",
        "yaml-language-server",
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
