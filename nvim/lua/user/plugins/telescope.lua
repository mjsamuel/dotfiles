local M = {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
	},
}

function M.config()
	require("telescope").setup({
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
			},
			selection_caret = "  ",
			entry_prefix = "  ",
			initial_mode = "insert",
			selection_strategy = "reset",
			sorting_strategy = "ascending",
			layout_strategy = "horizontal",
			file_ignore_patterns = { ".git/", "node_modules" },
			path_display = { "truncate" },
			winblend = 0,
			border = {},
			borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
			color_devicons = true,
			set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
			file_previewer = require("telescope.previewers").vim_buffer_cat.new,
			grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
			qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		},
		pickers = {
			buffers = {
				show_all_buffers = true,
				sort_lastused = true,
				theme = "ivy",
				mappings = {
					i = {
						[";"] = "delete_buffer",
						previewer = false,
					},
				},
			},
			find_files = { theme = "ivy" },
			git_commits = { theme = "ivy" },
			git_stash = { theme = "ivy" },
			git_status = { theme = "ivy" },
			help_tags = { theme = "ivy" },
			live_grep = { theme = "ivy" },
			lsp_implementations = { theme = "ivy" },
			lsp_references = { theme = "ivy" },
			registers = { theme = "ivy" },
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
			["ui-select"] = {
				require("telescope.themes").get_cursor(),
			},
		},
	})

	require("telescope").load_extension("fzf")
	require("telescope").load_extension("ui-select")
	require("telescope").load_extension("refactoring")
end

return M
