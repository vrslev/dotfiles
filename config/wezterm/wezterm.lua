local wezterm = require("wezterm")

return {
  check_for_updates = false,
  color_scheme = (wezterm.gui and wezterm.gui.get_appearance() or "Dark"):find("Dark") and "Vs Code Dark+ (Gogh)" or "Google (light) (terminal.sexy)",
  font = wezterm.font("FiraCode Nerd Font"),
  font_size = 15,
  initial_cols = 130,
  initial_rows = 36,
  window_decorations = "RESIZE",
  keys = {
    { key = 'UpArrow', mods = 'CMD', action = wezterm.action.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'CMD', action = wezterm.action.ScrollToPrompt(1) },
  },
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  line_height  = 1.1,
  quit_when_all_windows_are_closed  = false,
  window_close_confirmation  = "NeverPrompt",
}
