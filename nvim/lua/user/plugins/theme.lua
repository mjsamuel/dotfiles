function ToggleTheme()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
end

vim.cmd("colorscheme gruvbox-material")

vim.cmd("highlight! link CmpPmenu Pmenu")
vim.cmd("highlight! link CmpPmenuBorder Pmenu")
vim.cmd("highlight! CmpPmenu guibg=#282828")
vim.cmd("highlight! CmpPmenuBorder guifg=#615750")

vim.cmd([[highlight! NormalFloat guibg=#282828]])
vim.cmd([[highlight! FloatBorder guibg=#282828]])

