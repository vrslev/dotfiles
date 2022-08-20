local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

packer_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system(
    {'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path}
    )
  vim.cmd [[packadd packer.nvim]]
  vim.cmd [[autocmd User PackerComplete quitall]]
end

require("packer").init({
    autoremove = true,
})
require("packer").startup(function(use)
    use "wbthomason/packer.nvim"

    use 'lewis6991/impatient.nvim'
    use "projekt0n/github-nvim-theme"

    use ("nvim-treesitter/nvim-treesitter", {
        run = ":TSUpdate"
    })
    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context"
    }

    use {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        "jose-elias-alvarez/null-ls.nvim",
        
        "ray-x/lsp_signature.nvim",
        { "folke/trouble.nvim", "kyazdani42/nvim-web-devicons" },
        "j-hui/fidget.nvim",
        {"RishabhRD/lspactions", 'nvim-lua/popup.nvim'}
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

    use {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim'
    }

    use "gpanders/editorconfig.nvim"

    use "nvim-lualine/lualine.nvim"

    if packer_bootstrap then
        require("packer").sync()
    end
end)

return packer_bootstrap
