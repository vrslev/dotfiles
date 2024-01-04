---@type LazySpec[]
return {
	{ "lewis6991/gitsigns.nvim", event = "VeryLazy", opts = {} },
	{ "tpope/vim-fugitive", cmd = { "G", "Git" } },
	{
		"sontungexpt/url-open",
		event = "VeryLazy",
		keys = {
			{ "<leader>u", "<cmd>URLOpenUnderCursor<cr>" },
		},
		opts = {},
	},
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },
	{ "sudormrfbin/cheatsheet.nvim", event = "VeryLazy", opts = {} },
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{
				"<leader>sf",
				function()
					require("telescope.builtin").find_files({
						cwd = require("telescope.utils").buffer_dir(),
					})
				end,
			},
			{ "<leader>sg", "<Cmd>Telescope git_files<CR>" },
			{ "<leader>sb", "<Cmd>Telescope buffers<CR>" },
			{ "<leader>ss", "<Cmd>Telescope live_grep<CR>" },
		},
	},
	{
		"folke/trouble.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "TroubleToggle", "Trouble" },
		keys = {
			{ "<leader>lx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
		},
		opts = {},
	},
	{
		"m4xshen/hardtime.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
	},
}
