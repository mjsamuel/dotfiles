require("ayu").colorscheme()
require("github-theme")

function ToggleTheme()
	if vim.g.colors_name == "ayu" then
    print("toggle light")
    vim.cmd("colorscheme github_light")
    require('lualine').setup({options={theme="auto"}})
	else
    print("toggle dark")
    vim.cmd("colorscheme ayu-dark")
    require('lualine').setup({options={theme="ayu"}})
	end
end
