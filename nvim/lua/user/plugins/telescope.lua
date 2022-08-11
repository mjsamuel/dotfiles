local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		selection_caret = "  ",
		entry_prefix = "  ",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		mappings = {
			i = {
				["ESC"] = actions.close,
			},
		},
		file_ignore_patterns = { ".git/" },
		path_display = { "truncate" },
		color_devicons = true,
		border = {},
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		buffers = {
			ignore_current_buffer = true,
			sort_lastused = true,
		},
	},
	extension = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

require("telescope").load_extension("fzf")
