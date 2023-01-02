local M = {
	"sainnhe/gruvbox-material",
	lazy = false,
	priority = 1000,
}

local function set_highlights()
	vim.cmd("highlight! Pmenu guibg=background")
	vim.cmd("highlight! link CmpPmenu Pmenu")
	vim.cmd("highlight! link CmpPmenuBorder Pmenu")
	vim.cmd("highlight! link NormalFloat Pmenu")
	vim.cmd("highlight! link FloatBorder Pmenu")

	local configuration = vim.fn["gruvbox_material#get_configuration"]()
	local palette = vim.fn["gruvbox_material#get_palette"](
		configuration.background,
		configuration.foreground,
		configuration.colors_override
	)

	local navic_highlights = {
		"NavicIconsFile",
		"NavicIconsModule",
		"NavicIconsNamespace",
		"NavicIconsPackage",
		"NavicIconsClass",
		"NavicIconsMethod",
		"NavicIconsProperty",
		"NavicIconsField",
		"NavicIconsConstructor",
		"NavicIconsEnum",
		"NavicIconsInterface",
		"NavicIconsFunction",
		"NavicIconsVariable",
		"NavicIconsConstant",
		"NavicIconsString",
		"NavicIconsNumber",
		"NavicIconsBoolean",
		"NavicIconsArray",
		"NavicIconsObject",
		"NavicIconsKey",
		"NavicIconsNull",
		"NavicIconsEnumMember",
		"NavicIconsStruct",
		"NavicIconsEvent",
		"NavicIconsOperator",
		"NavicIconsTypeParameter",
	}

	for _, highlight_group in ipairs(navic_highlights) do
		vim.api.nvim_set_hl(0, highlight_group, {
			default = true,
			bg = palette.bg1[1],
			fg = palette.yellow[1],
		})
	end
end

function M.config()
	vim.cmd("colorscheme gruvbox-material")
	set_highlights()

	function ToggleTheme()
		if vim.o.background == "dark" then
			vim.o.background = "light"
		else
			vim.o.background = "dark"
		end
		set_highlights()
	end
end

return M
