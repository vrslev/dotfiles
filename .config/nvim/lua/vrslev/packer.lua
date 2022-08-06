require("packer").startup(function ()
	use "wbthomason/packer.nvim"
	
	use 'neovim/nvim-lspconfig'

	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use "onsails/lspkind-nvim"

	use "williamboman/mason.nvim"
	use "williamboman/mason-lspconfig.nvim"

	use "projekt0n/github-nvim-theme"
    -- use "f-person/auto-dark-mode.nvim"

end)
