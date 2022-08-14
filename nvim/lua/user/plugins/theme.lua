-- local ayu = require("ayu")
-- local colors = require("ayu.colors")
--
-- ayu.setup({
-- 	overrides = {
-- 		IncSearch = { bg = "#FFB454", fg = "#0A0E14" },
-- 	},
-- })
-- ayu.colorscheme()

vim.cmd("colorscheme gruvbox-material")

function ToggleTheme()
	if vim.o.background == "dark" then
    vim.o.background = "light"
	else
    vim.o.background = "dark"
	end
end

vim.keymap.set("n", "<leader>s", ":lua ToggleTheme()<cr>")
