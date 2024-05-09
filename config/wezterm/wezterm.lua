local wezterm = require("wezterm")

local config = {}

config.check_for_updates = false
-- Google (light) (terminal.sexy) or Vs Code Light+ (Gogh) are also good
-- config.color_scheme = wezterm.gui.get_appearance():find("Dark") and "Vs Code Dark+ (Gogh)" or "Google (light) (terminal.sexy)"
config.color_scheme = "Vs Code Dark+ (Gogh)"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 15
config.initial_cols = 130
config.initial_rows = 36
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.keys = {
	{ key = 'UpArrow', mods = 'CMD', action = wezterm.action.ScrollToPrompt(-1) },
	{ key = 'DownArrow', mods = 'CMD', action = wezterm.action.ScrollToPrompt(1) },
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.line_height = 1.1

return config
