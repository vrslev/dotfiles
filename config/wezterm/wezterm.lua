local wezterm = require("wezterm")

local config = {}

config.check_for_updates = false
-- Google (light) (terminal.sexy) or Vs Code Light+ (Gogh) are also good
-- config.color_scheme = wezterm.gui.get_appearance():find("Dark") and "Vs Code Dark+ (Gogh)" or "Google (light) (terminal.sexy)"
config.color_scheme = "Vs Code Dark+ (Gogh)"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 15
config.hyperlink_rules = {
	-- Linkify things that look like URLs and the host has a TLD name.
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
		format = "$0",
	},

	-- linkify email addresses
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
		format = "mailto:$0",
	},

	-- file:// URI
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\bfile://\S*\b]],
		format = "$0",
	},

	-- Linkify things that look like URLs with numeric addresses as hosts.
	-- E.g. http://127.0.0.1:8000 for a local development server,
	-- or http://192.168.1.1 for the web interface of many routers.
	{
		regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
		format = "$0",
	},
}
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
