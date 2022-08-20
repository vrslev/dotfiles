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