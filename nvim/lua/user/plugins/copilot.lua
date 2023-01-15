local M = {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "VeryLazy",
}

M.config = {
	panel = { enabled = false },
	suggestion = {
		auto_trigger = true,
		keymap = {
			accept = "<M-Enter>",
			prev = false,
			next = false,
			dismiss = "<M-Esc>",
		},
	},
}

return M
