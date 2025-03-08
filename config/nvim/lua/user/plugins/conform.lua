local M = {
  'stevearc/conform.nvim',
}

local prettier = { "prettierd", lsp_format = "fallback", stop_after_first = true }

M.opts = {
  default_format_opts = { lsp_format = "fallback" },
  formatters_by_ft = {
    css = prettier,
    html = prettier,
    htmlangular = prettier,
    javascript = prettier,
    json = prettier,
    python = { "black" },
    scss = prettier,
    sh = { "shfmt" },
    sql = { "sqlfmt" },
    typescript = prettier,
  },
}

return M
