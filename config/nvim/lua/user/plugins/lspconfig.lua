local M = {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  cmd = "LspInfo",
  dependencies = "mason-lspconfig.nvim",
}

function M.config()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

  local language_servers = {
    angularls = {},
    bashls = {},
    cmake = {},
    cssls = {},
    emmet_ls = {},
    html = {},
    jsonls = {},
    lua_ls = {},
    marksman = {},
    pyright = {},
    tailwindcss = {},
    tsserver = {},
  }

  for ls, settings in pairs(language_servers) do
    lspconfig[ls].setup({
      capabilities = capabilities,
      settings = settings,
    })
  end

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
