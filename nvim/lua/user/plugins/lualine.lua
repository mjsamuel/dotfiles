local M = {
	"nvim-lualine/lualine.nvim",
	lazy = false,
}

function M.config()
	require("lualine").setup({
		options = {
			globalstatus = true,
			theme = "gruvbox-material",
			section_separators = "",
			component_separators = "",
			disabled_filetypes = { "alpha" },
		},
	})
end

return M
