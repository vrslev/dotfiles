local os_is_dark = vim.call('system', 'defaults read -globalDomain AppleInterfaceStyle'):find('Dark') ~= nil
local theme_style = os_is_dark and "dark" or "light"

require('github-theme').setup {
    theme_style = theme_style,
    dark_float = true,
    sidebars = {"packer", "mason", "trouble"},
}