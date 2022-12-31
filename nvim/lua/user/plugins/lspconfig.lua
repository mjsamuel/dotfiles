local M = {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
}

function M.config()
	local lspconfig = require("lspconfig")
	local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = {
			border = require("user.misc.opts").border,
		}
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end

	lspconfig["angularls"].setup({
		capabilities = capabilities,
	})

	lspconfig["bashls"].setup({
		capabilities = capabilities,
	})

	lspconfig["cmake"].setup({
		capabilities = capabilities,
	})

	lspconfig["cssls"].setup({
		capabilities = capabilities,
	})

	lspconfig["dockerls"].setup({
		capabilities = capabilities,
	})

	lspconfig["emmet_ls"].setup({
		capabilities = capabilities,
	})

	lspconfig["html"].setup({
		capabilities = capabilities,
	})

	lspconfig["jsonls"].setup({
		capabilities = capabilities,
	})

	lspconfig["lemminx"].setup({
		capabilities = capabilities,
	})

	lspconfig["marksman"].setup({
		capabilities = capabilities,
	})

	lspconfig["pyright"].setup({
		capabilities = capabilities,
	})

	lspconfig["sourcekit"].setup({
		capabilities = capabilities,
	})

	lspconfig["sqlls"].setup({
		capabilities = capabilities,
	})

	lspconfig["sumneko_lua"].setup({
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	})

	lspconfig["tailwindcss"].setup({
		capabilities = capabilities,
	})

	lspconfig["taplo"].setup({
		capabilities = capabilities,
	})

	lspconfig["tsserver"].setup({
		capabilities = capabilities,
	})

	lspconfig["yamlls"].setup({
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
end

return M
