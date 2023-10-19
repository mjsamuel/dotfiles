local M = {
  "jose-elias-alvarez/null-ls.nvim",
  event = "BufReadPre",
}

M.config = function()
  local null_ls = require("null-ls")

  local cspell_filetypes = { "markdown", "text", "gitcommit" }

  null_ls.setup({
    sources = {
      -- diagnostics
      null_ls.builtins.diagnostics.cspell.with({
        filetypes = cspell_filetypes,
      }),
      -- code actions
      null_ls.builtins.code_actions.cspell.with({
        filetypes = cspell_filetypes,
      }),
      -- formatting
      null_ls.builtins.formatting.black,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.sql_formatter,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.xmlformat,
    },
  })
end

return M
