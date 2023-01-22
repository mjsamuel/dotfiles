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

function ToggleTheme()
	if vim.o.background == "dark" then
		vim.o.background = "light"
	else
		vim.o.background = "dark"
	end
	set_highlights()
end

local function in_os_dark_mode()
	if vim.fn.has("mac") == 1 then
		vim.fn.system("defaults read -g AppleInterfaceStyle")
	elseif vim.fn.has("win32unix") then
		vim.fn.system(
			'powershell.exe "Get-ItemProperty -Path HKCU:SOFTWAREMicrosoftWindowsCurrentVersionThemesPersonalize -Name AppsUseLightTheme" | grep 0'
		)
	end
	return vim.g.shell_error
end

function M.config()
	vim.cmd("colorscheme gruvbox-material")
	if in_os_dark_mode() then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
	set_highlights()
end

return M
