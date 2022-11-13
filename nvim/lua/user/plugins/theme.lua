function ToggleTheme()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
end

vim.cmd("colorscheme gruvbox-material")

vim.cmd("highlight! Pmenu guibg=#282828")
vim.cmd("highlight! link CmpPmenu Pmenu")
vim.cmd("highlight! link CmpPmenuBorder Pmenu")
vim.cmd("highlight! link NormalFloat Pmenu")
vim.cmd("highlight! link FloatBorder Pmenu")

vim.cmd("highlight! link TreesitterContext CursorLine")

