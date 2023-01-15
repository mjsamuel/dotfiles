local M = {
	"mhartington/formatter.nvim",
	cmd = "Format",
}

function M.config()
	local util = require("formatter.util")

	require("formatter").setup({
		filetype = {
			html = { require("formatter.filetypes.html").prettier },
			javascript = { require("formatter.filetypes.javascript").prettier },
			javascriptreact = { require("formatter.filetypes.javascriptreact").prettier },
			json = { require("formatter.filetypes.json").prettier },
			lua = { require("formatter.filetypes.lua").stylua },
			markdown = { require("formatter.filetypes.markdown").markdownlint },
			python = { require("formatter.filetypes.python").autopep8 },
			typescript = { require("formatter.filetypes.typescript").prettier },
			typescriptreact = { require("formatter.filetypes.typescriptreact").prettier },
			sql = {
				{
					exe = "sql-formatter",
					args = { util.escape_path(util.get_current_buffer_file_path()) },
					stdin = true,
				},
			},
		},
	})
end

return M
