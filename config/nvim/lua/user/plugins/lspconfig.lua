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
    ["ts_ls"] = function()
      -- typescript-tools is used instead
    end,
    ["tailwindcss"] = function()
      lspconfig["tailwindcss"].setup({
        capabilities = capabilities,
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
  })

  -- appearance tweaks
  require("lspconfig.ui.windows").default_options.border = "rounded"
  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = { border = "rounded" }
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end

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
