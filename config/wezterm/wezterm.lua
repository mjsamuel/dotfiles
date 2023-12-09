local wezterm = require("wezterm")
local action = wezterm.action
local appearance = wezterm.gui.get_appearance

local config = {
  -- Appearance
  adjust_window_size_when_changing_font_size = false,
  color_scheme = appearance():find("Dark") and "rose-pine" or "rose-pine-dawn",
  cursor_blink_rate = 0,
  font = wezterm.font("FiraCode Nerd Font Mono"),
  font_size = 20,
  hide_tab_bar_if_only_one_tab = true,
  line_height = 1.1,
  macos_window_background_blur = 100,
  native_macos_fullscreen_mode = true,
  window_background_opacity = 1,
  window_decorations = "RESIZE",
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  -- Keybindings
  keys = {
    { key = "Enter", mods = "ALT", action = action.DisableDefaultAssignment },
    { key = "f", mods = "CMD", action = action.ToggleFullScreen },
    { key = "+", mods = "CMD", action = action.IncreaseFontSize },
    { key = "=", mods = "CMD", action = action.ResetFontSize },
  },
}

-- Windows specfic config
if string.match(wezterm.target_triple, "windows") then
  config.default_prog = { "wsl", "--cd", "~" }
  config.font_size = 14
  config.window_decorations = "TITLE|RESIZE"
  -- Keybindings
  table.insert(config.keys, { key = "F11", action = action.ToggleFullScreen })
  table.insert(config.keys, { key = "v", mods = "CTRL", action = action.PasteFrom("Clipboard") })
  table.insert(config.keys, { key = "=", mods = "CTRL", action = action.ResetFontSize })
end

return config
