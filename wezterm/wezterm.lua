local wezterm = require("wezterm")
local act = wezterm.action

return {
	-- Appearance
	font = wezterm.font("FiraCode Nerd Font Mono"),
	font_size = 18,
	color_scheme = "Gruvbox dark, medium (base16)",
	window_padding = { left = 10, right = 1, top = 32, bottom = 0 },
	-- Keybindings
	keys = {
		{ key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
		{ key = "f", mods = "CMD", action = act.ToggleFullScreen },
	},
	-- Misc
	window_close_confirmation = "NeverPrompt",
	hide_tab_bar_if_only_one_tab = true,
  window_decorations = "RESIZE",
  native_macos_fullscreen_mode = true
}
