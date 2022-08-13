local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local install_plugins = false
local packer_url = 'https://github.com/wbthomason/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  print('Installing packer...')
  vim.fn.system {'git', 'clone', '--depth', '1', packer_url, install_path}
  print('Done.')

  vim.cmd('packadd packer.nvim')
end

require("packer").startup(function (use)
	use "wbthomason/packer.nvim"

    use 'lewis6991/impatient.nvim'
    use "projekt0n/github-nvim-theme"

    use("nvim-treesitter/nvim-treesitter", {
        run = ":TSUpdate"
    })
    use "nvim-treesitter/nvim-treesitter-context"

    use {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        "jose-elias-alvarez/null-ls.nvim"
    }

    use {
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',

        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',

        "onsails/lspkind.nvim"
    }

    use {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim'
    }

    use "gpanders/editorconfig.nvim"

    use "nvim-lualine/lualine.nvim"
end)
