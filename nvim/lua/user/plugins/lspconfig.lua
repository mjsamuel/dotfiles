local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspconfig")["angularls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["bashls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["cmake"].setup({
	capabilities = capabilities,
})

require("lspconfig")["cssls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["dockerls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["emmet_ls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["html"].setup({
	capabilities = capabilities,
})

require("lspconfig")["jdtls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["jsonls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["lemminx"].setup({
	capabilities = capabilities,
})

require("lspconfig")["marksman"].setup({
	capabilities = capabilities,
})

require("lspconfig")["pyright"].setup({
	capabilities = capabilities,
})

require("lspconfig")["sourcekit"].setup({
	capabilities = capabilities,
})

require("lspconfig")["sqlls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["sumneko_lua"].setup({
	capabilities = capabilities,
})

require("lspconfig")["tailwindcss"].setup({
	capabilities = capabilities,
})

require("lspconfig")["taplo"].setup({
	capabilities = capabilities,
})

require("lspconfig")["tsserver"].setup({
	capabilities = capabilities,
})

require("lspconfig")["yamlls"].setup({
	capabilities = capabilities,
})

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
