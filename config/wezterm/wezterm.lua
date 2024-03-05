local wezterm = require("wezterm")

local color_scheme = wezterm.gui.get_appearance():find("Dark") and "Vs Code Dark+ (Gogh)" or "github_light"

local hyperlink_rules = {
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

return {
	check_for_updates = false,
	color_scheme = color_scheme,
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 15,
	hyperlink_rules = hyperlink_rules,
	initial_cols = 130,
	initial_rows = 36,
	window_decorations = "RESIZE",
	enable_tab_bar = true,
	keys = {
		{
			key = "f",
			mods = "SUPER|CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	line_height = 1.1,
}
