local wezterm = require("wezterm")
local act = wezterm.action

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "tokyonight"
	else
		return "tokyonight-day"
	end
end

return {
	-- Appearance
	font = wezterm.font("FiraCode Nerd Font Mono"),
	font_size = 18,
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
	-- Keybindings
	keys = {
		{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "f", mods = "CMD", action = act.ToggleFullScreen },
	},
	-- Misc
	window_close_confirmation = "NeverPrompt",
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",
	native_macos_fullscreen_mode = true,
}
