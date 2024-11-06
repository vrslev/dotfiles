local wezterm = require("wezterm")

local config = {}

config.check_for_updates = false

function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return "Vs Code Dark+ (Gogh)"
  else
    return "Google (light) (terminal.sexy)"
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 15
config.initial_cols = 130
config.initial_rows = 36
config.window_decorations = "RESIZE"
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
config.quit_when_all_windows_are_closed = false
config.window_close_confirmation = "NeverPrompt"

return config
