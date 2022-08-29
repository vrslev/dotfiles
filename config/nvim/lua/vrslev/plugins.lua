local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    print("Installing packer")
    packer_bootstrap = vim.fn.system {
        'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path
    }
    vim.cmd "packadd packer.nvim"
    vim.cmd "autocmd User PackerComplete quitall"
end

local packer = require("packer")
packer.init { autoremove = true }
packer.startup(function(use)
    use "wbthomason/packer.nvim"

    -- Speedups
    use 'lewis6991/impatient.nvim'

    -- UI
    use {
        "projekt0n/github-nvim-theme",
        "nvim-lualine/lualine.nvim",
        'RRethy/vim-illuminate',
        "lukas-reineke/indent-blankline.nvim"
    }

    -- Tree-sitter
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", requires = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
        "p00f/nvim-ts-rainbow",
    } }

    -- LSP
    use {
        'junnplus/lsp-setup.nvim',
        requires = {
            "neovim/nvim-lspconfig",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        }
    }
    use 'WhoIsSethDaniel/mason-tool-installer.nvim'
    use "jose-elias-alvarez/null-ls.nvim"
    use "ray-x/lsp_signature.nvim"
    use "j-hui/fidget.nvim"
    use { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" }
    use { "RishabhRD/lspactions", requires = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim' } }
    use 'folke/lua-dev.nvim'

    -- Completion
    use { 'hrsh7th/nvim-cmp', tag = "v0.0.1", requires = {
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        "hrsh7th/cmp-cmdline",
    } }
    use 'L3MON4D3/LuaSnip'
    use "onsails/lspkind.nvim"

    -- Misc
    use "gpanders/editorconfig.nvim"
    use { 'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim' }
    use {
        "nvim-neo-tree/neo-tree.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        }
    }
    use "windwp/nvim-autopairs"
    use 'numToStr/Comment.nvim'
    use 'rmagatti/auto-session'
    use 'folke/which-key.nvim'

    if packer_bootstrap then
        packer.sync()
    end
end)

return packer_bootstrap
