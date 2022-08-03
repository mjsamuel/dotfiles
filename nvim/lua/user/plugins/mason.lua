require("mason").setup()

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
    "firefox-debug-adapter"
	},
  run_on_start = true,
  start_delay = 15000
})
