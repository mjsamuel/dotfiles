local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  cmd = "LspInfo",
}

function M.config()
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  mason_lspconfig.setup_handlers({
    function(server_name) -- default handler
      lspconfig[server_name].setup({ capabilities = capabilities })
    end,
    ["emmet_ls"] = function()
      local filetypes = lspconfig["emmet_ls"].config_def.default_config.filetypes
      table.insert(filetypes, "gotmpl")
      lspconfig["emmet_ls"].setup({
        capabilities = capabilities,
        filetypes = filetypes,
      })
    end,
  })

  vim.diagnostic.config({
    float = { border = "rounded" },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      }
    }
  })
end

return M
