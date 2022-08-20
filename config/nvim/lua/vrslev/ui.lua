local os_is_dark = vim.call('system', 'defaults read -globalDomain AppleInterfaceStyle'):find('Dark') ~= nil
local theme_style = os_is_dark and "dark" or "light"

require('illuminate').configure {}

for _, group in pairs({ "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite" }) do
    vim.api.nvim_set_hl(0, group, { link = "Visual" })
end

require('github-theme').setup {
    theme_style = theme_style,
    dark_float = true,
    sidebars = { "packer", "mason", "trouble" },
    overrides = function(c)
        -- https://github.com/p00f/nvim-ts-rainbow/issues/81#issuecomment-1058124957
        local rainbow = {c.bright_blue, c.bright_orange, c.bright_magenta, c.bright_red, c.bright_yellow, c.bright_green,  c.bright_cyan}

        for idx, color in ipairs(rainbow) do
            -- print(("hi rainbowcol%d guifg=%s"):format(idx, color))
            vim.cmd(("hi rainbowcol%d guifg=%s"):format(idx, color))
        end

        return {}
    end,
}

require('lualine').setup {
    sections = {
        lualine_c = {},
        lualine_x = { 'encoding', 'filetype' },
    },
    tabline = {
        lualine_a = { 'buffers' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'tabs' }
    },
    options = {
        component_separators = '',
        section_separators = '',
    }
}

require("indent_blankline").setup {
    show_current_context = true,
    show_current_context_start = true,
}
