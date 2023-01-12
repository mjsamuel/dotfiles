local M = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPost",
}

function M.config()
	require("nvim-treesitter.configs").setup({
		ensure_install = { "lua", "typescript", "java", "json", "markdown", "make", "python" },
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
			disable = { "NvimTree" },
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true },
		context_commentstring = {
			enable = true,
		},
	})
end

return M
