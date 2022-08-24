require("treesitter-context").setup({
	enable = true,
	max_lines = 0,
	trim_scope = "outer",
	patterns = {
		default = {
			"class",
			"function",
			"for",
			"while",
			"if",
			"switch",
			"case",
		},
		json = {
			"object",
			"pair",
		},
		ts = {
			"object",
			"pair",
		},
	},
})
