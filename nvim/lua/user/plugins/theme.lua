local ayu = require("ayu")
local colors = require("ayu.colors")

ayu.setup({
	overrides = {
		IncSearch = { bg = "#FFB454", fg = "#0A0E14" },
	},
})
ayu.colorscheme()

-- vim.cmd("colorscheme duskfox")
--
-- function ToggleTheme()
-- 	if vim.g.colors_name == "duskfox" then
--     vim.cmd("colorscheme dawnfox")
-- 	else
--     vim.cmd("colorscheme duskfox")
-- 	end
-- end
--
-- vim.keymap.set("n", "<leader>s", ":lua ToggleTheme()<cr>")
