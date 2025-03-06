local M = {
  'stevearc/conform.nvim',
}

local prettier = { "prettierd", "prettier", stop_after_first = true }

M.opts = {
  formatters_by_ft = {
    css = prettier,
    go = { lsp_format = "fallback" },
    html = prettier,
    htmlangular = prettier,
    javascript = prettier,
    json = prettier,
    lua = { lsp_format = "fallback" },
    python = { "black" },
    scss = prettier,
    shell = { "shfmt" },
    sql = { "sqlfmt" },
    typescript = prettier,
  },
}

return M
