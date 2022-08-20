local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
packer_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system {
    'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path
}
  vim.cmd [[packadd packer.nvim]]
  vim.cmd [[autocmd User PackerComplete quitall]]
end

local packer = require("packer")
packer.init { autoremove = true }
packer.startup(function(use)
    use "wbthomason/packer.nvim"

    use 'lewis6991/impatient.nvim'
    use "projekt0n/github-nvim-theme"
    use {"nvim-lualine/lualine.nvim", config = function() require("vrslev.plugins.lualine") end}
    use "gpanders/editorconfig.nvim"
    use 'nvim-lua/plenary.nvim'
    use {'nvim-telescope/telescope.nvim', config = function() require("vrslev.plugins.telescope") end}
    use {
        "nvim-neo-tree/neo-tree.nvim",
        requires = {"MunifTanjim/nui.nvim"},
        config = function() require("vrslev.plugins.neo-tree") end,
    }
    use {"windwp/nvim-autopairs", config = function() require("vrslev.plugins.nvim-autopairs") end}

    use {
        {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"},
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
    }

    use {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        "jose-elias-alvarez/null-ls.nvim",
        
        "ray-x/lsp_signature.nvim",
        "j-hui/fidget.nvim",
        { "folke/trouble.nvim", "kyazdani42/nvim-web-devicons" },
        {"RishabhRD/lspactions", 'nvim-lua/popup.nvim'},
    }
    
    use {
        { 'hrsh7th/nvim-cmp', tag = "v0.0.1" },
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        "hrsh7th/cmp-cmdline",
        
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
        
        "onsails/lspkind.nvim"
    }

    if packer_bootstrap then
        packer.sync()
    end
end)

return packer_bootstrap
