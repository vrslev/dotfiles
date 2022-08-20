local os_is_dark = vim.call('system', 'defaults read -globalDomain AppleInterfaceStyle'):find('Dark') ~= nil
local theme_style = os_is_dark and "dark" or "light"

require('illuminate').configure {}

for _, group in pairs({"IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite"}) do
    vim.api.nvim_set_hl(0, group, { link = "Visual" })
end

require('github-theme').setup {
    theme_style = theme_style,
    dark_float = true,
    sidebars = {"packer", "mason", "trouble"},
}

require('lualine').setup {
    sections = {
        lualine_c = {},
        lualine_x = {'encoding', 'filetype'},
    },
    tabline = {
        lualine_a = {'buffers'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'tabs'}
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
