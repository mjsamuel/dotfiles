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
    ["tailwindcss"] = function()
      local filetypes = lspconfig["tailwindcss"].config_def.default_config.filetypes
      table.insert(filetypes, "gotmpl")
      lspconfig["tailwindcss"].setup({
        capabilities = capabilities,
        filetypes = filetypes,
        root_dir = function(fname)
          local root_pattern = lspconfig.util.root_pattern(
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts"
          )
          return root_pattern(fname)
        end,
      })
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
