local github_theme = require('github-theme')

function set_light()
    github_theme.setup { theme_style = 'light' }
end

function set_dark()
    github_theme.setup { theme_style = 'dark' }
end

function os_is_dark()
    return vim.call('system', 'defaults read -globalDomain AppleInterfaceStyle'):find('Dark') ~= nil
end

if os_is_dark() then
    set_dark()
else
    set_light()
end

--[[
local auto_dark_mode = require('auto-dark-mode')
auto_dark_mode.setup {
	update_interval = 1000,
    set_dark_mode = set_dark,	
	set_light_mode = set_light,
}
auto_dark_mode.init()
]]--
