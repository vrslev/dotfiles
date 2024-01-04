local function active_statusline()
	local st = require("mini.statusline")

	local mode, mode_hl = st.section_mode({ trunc_width = 120 })
	local git = st.section_git({ trunc_width = 75 })
	local diagnostics = st.section_diagnostics({ trunc_width = 75 })
	local filename = st.section_filename({ trunc_width = 140 })
	local location = st.section_location({ trunc_width = 75 })
	local search = st.section_searchcount({ trunc_width = 75 })

	return st.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
		"%<", -- Mark general truncate point
		{ hl = "MiniStatuslineFilename", strings = { filename } },
		"%=", -- End left alignment
		{ hl = mode_hl, strings = { search, location } },
	})
end

---@type LazySpec[]
return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {},
	},
	-- {
	-- 	"projekt0n/github-nvim-theme",
	-- 	priority = 1000,
	-- 	main = "github-theme",
	-- 	opts = {
	-- 		darken = {
	-- 			floats = true,
	-- 		},
	-- 		groups = {
	-- 			all = {
	-- 				DiagnosticHint = { fg = "fg0" },
	-- 				TSDefinitionUsage = { bg = "bg2" },
	-- 			},
	-- 		},
	-- 	},
	-- },
	{
		"echasnovski/mini.statusline",
		priority = 900,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			content = { active = active_statusline },
		},
	},
	{
		"echasnovski/mini.indentscope",
		event = "VeryLazy",
		opts = {
			draw = {
				delay = 0,
				animation = function()
					return 0
				end,
			},
			mappings = {
				object_scope = "",
				object_scope_with_border = "",
				goto_top = "",
				goto_bottom = "",
			},
			symbol = "│",
		},
	},
}
