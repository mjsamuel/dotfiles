local M = {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = "mason-lspconfig.nvim",
}

function M.config()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

  require("lspconfig.ui.windows").default_options.border = "rounded"

  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = { border = require("user.misc.opts").border }
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end

  local language_servers = {
    angularls = {},
    bashls = {},
    cmake = {},
    cssls = {},
    dockerls = {},
    emmet_ls = {},
    html = {},
    jsonls = {},
    lemminx = {
      xml = {
        server = {
          workDir = os.getenv("XDG_CACHE_HOME") .. "/lemminx",
        },
      },
    },
    marksman = {},
    pyright = {},
    sqlls = {},
    tailwindcss = {},
    taplo = {},
    tsserver = {},
    yamlls = {},
    lua_ls = {},
  }

  for ls, settings in pairs(language_servers) do
    lspconfig[ls].setup({
      capabilities = capabilities,
      settings = settings,
    })
  end

  local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
end

return M
