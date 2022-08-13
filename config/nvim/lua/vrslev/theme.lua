function get_theme_style()
    local os_is_dark = vim.call('system', 'defaults read -globalDomain AppleInterfaceStyle'):find('Dark') ~= nil
    return os_is_dark and "dark" or "light"
end

require('github-theme').setup { theme_style = get_theme_style() }