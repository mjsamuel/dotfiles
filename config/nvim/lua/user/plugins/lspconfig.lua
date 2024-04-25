local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  cmd = "LspInfo",
  dependencies = "mason-lspconfig.nvim",
}

function M.config()
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

  mason_lspconfig.setup_handlers({
    function(server_name) -- default handler
      lspconfig[server_name].setup({ capabilities = capabilities })
    end,
    ["tsserver"] = function()
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

  local signs = require("user.misc.opts").signs
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
end

return M
