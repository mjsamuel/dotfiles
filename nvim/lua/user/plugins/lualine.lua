local M = { "nvim-lualine/lualine.nvim" }

function M.config()
	require("lualine").setup({
		options = {
			globalstatus = true,
			theme = "gruvbox-material",
			section_separators = "",
			component_separators = "",
		},
	})
end

return M
