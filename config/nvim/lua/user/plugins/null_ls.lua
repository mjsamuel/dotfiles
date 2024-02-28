local M = {
  "nvimtools/none-ls.nvim",
  event = "BufReadPre",
}

M.config = function()
  local null_ls = require("null-ls")

  null_ls.setup({
    sources = {
      -- formatting
      null_ls.builtins.formatting.black,
      null_ls.builtins.formatting.ocamlformat,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.formatting.sql_formatter,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.lemminx,
    },
  })
end

return M
