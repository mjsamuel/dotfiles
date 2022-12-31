local M = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPost",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
	},
}

function M.config()
	require("nvim-treesitter.configs").setup({
		ensure_install = { "lua", "typescript", "java", "json", "markdown", "make", "python" },
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
			disable = { "NvimTree" },
			additional_vim_regex_highlighting = true,
		},
		indent = { enable = true },
		context_commentstring = {
			enable = true,
		},
	})
end

return M
