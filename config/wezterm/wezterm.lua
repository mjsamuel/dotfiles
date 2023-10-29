local wezterm = require("wezterm")
local action = wezterm.action

local function scheme_for_appearance(appearance)
  return appearance:find("Dark") and "tokyonight_night" or "tokyonight_day"
end

return {
  -- Appearance
  font = wezterm.font("FiraCode Nerd Font Mono"),
  font_size = 20,
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  adjust_window_size_when_changing_font_size = false,
  cursor_blink_rate = 0,
  line_height = 1.1,
  -- Keybindings
  keys = {
    { key = "Enter", mods = "ALT", action = action.DisableDefaultAssignment },
    { key = "f",     mods = "CMD", action = action.ToggleFullScreen },
  },
  -- Misc
  hide_tab_bar_if_only_one_tab = true,
  window_decorations = "RESIZE",
  native_macos_fullscreen_mode = true,
}
