local M = {
	"williamboman/mason.nvim",
	event = "BufReadPre",
  cmd = "Mason",
	dependencies = {
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			config = function()
				require("mason-tool-installer").setup({
					ensure_installed = {
						"angular-language-server",
						"bash-language-server",
						"cmake-language-server",
						"css-lsp",
						"dockerfile-language-server",
						"emmet-ls",
						"html-lsp",
						"jdtls",
						"json-lsp",
						"lemminx",
						"lua-language-server",
						"marksman",
						"prettier",
						"pyright",
						"sqlls",
						"stylua",
						"tailwindcss-language-server",
						"taplo",
						"typescript-language-server",
						"yaml-language-server",
						"stylua",
						"prettier",
						"firefox-debug-adapter",
					},
					run_on_start = true,
					start_delay = 15000,
				})
			end,
		},
	},
}

function M.config()
	require("mason").setup({
		ui = {
			border = require("user.misc.opts").border,
		},
	})
end

return M
