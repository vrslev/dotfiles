require('nvim-treesitter.configs').setup {
    ensure_installed = "all",
    sync_install = false,
    -- phpdoc doesn't compile on Apple M1
    ignore_install = { "phpdoc" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    textobjects = {
        select = {
          enable = true,
          lookahead = true,
    
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = true,
        },
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
      termcolors = {
        "Blue",
        "White",
        "Magenta",
        "Red",
        "Yellow",
        "Green",
        "Cyan",
    }
    }
}

require('treesitter-context').setup()
