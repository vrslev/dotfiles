---@type LazySpec[]
return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
		opts = {
			-- https://github.com/stevearc/conform.nvim/tree/master#options
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				yaml = { "prettierd" },
				["_"] = { "trim_whitespace" },
			},
			format_on_save = {
				timeout_ms = 10000,
				lsp_fallback = true,
			},
		},
	},
	{ "echasnovski/mini.comment", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.bracketed", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.surround", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.move", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.operators", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
}
