local wezterm = require("wezterm")
local action = wezterm.action
local appearance = wezterm.gui.get_appearance

return {
  -- Appearance
  font = wezterm.font("FiraCode Nerd Font Mono"),
  font_size = 20,
  color_scheme = appearance():find("Dark") and "rose-pine" or "rose-pine-dawn",
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  adjust_window_size_when_changing_font_size = false,
  cursor_blink_rate = 0,
  line_height = 1.1,
  window_background_opacity = 0.95,
  macos_window_background_blur = 100,
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
