local M = {
  "nvimtools/none-ls.nvim",
  event = "BufReadPre",
}

M.config = function()
  local null_ls = require("null-ls")
  local mason_null_ls = require("mason-null-ls")

  null_ls.setup({})
  mason_null_ls.setup({
    ensure_installed = {},
    automatic_installation = false,
    handlers = {
      prettierd = function()
        local config = null_ls.builtins.formatting.prettierd
        config.filetypes = vim.tbl_extend("force", config.filetypes, { "gotmpl" })
        null_ls.register(config)
      end,
    }
  })
end

return M
