local modicator = require("modicator")

modicator.setup({
	-- NOTE: Modicator requires line_numbers and cursorline to be enabled
	line_numbers = true,
	cursorline = true,
	highlights = {
		modes = {
			["n"] = modicator.get_highlight_fg("CursorLineNr"),
			["i"] = "#A9B665",
			["v"] = "#EA6962",
			["V"] = "#EA6962",
			["�"] = modicator.get_highlight_fg("Type"),
			["s"] = modicator.get_highlight_fg("Keyword"),
			["S"] = modicator.get_highlight_fg("Keyword"),
			["R"] = "#D8A657",
			["c"] = modicator.get_highlight_fg("Constant"),
		},
	},
})
