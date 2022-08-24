require("formatter").setup({
	filetype = {
		lua = { require("formatter.filetypes.lua").stylua },
		typescript = { require("formatter.filetypes.typescript").prettier },
		html = { require("formatter.filetypes.html").prettier },
		json = { require("formatter.filetypes.json").prettier },
	},
})
