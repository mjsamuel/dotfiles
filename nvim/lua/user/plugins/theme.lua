require("ayu").colorscheme()

function ToggleTheme()
	if vim.g.colors_name == "ayu" then
    -- vim.cmd("colorscheme github_light")
    require('lualine').setup({options={theme="auto"}})
	else
    vim.cmd("colorscheme ayu-dark")
    require('lualine').setup({options={theme="ayu"}})
	end
end
