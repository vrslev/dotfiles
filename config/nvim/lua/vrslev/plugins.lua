---@type LazySpec[]
local appearance = {
	{
		"projekt0n/github-nvim-theme",
		priority = 1000,
		main = "github-theme",
		opts = {
			darken = {
				floats = true,
			},
			groups = {
				all = {
					DiagnosticHint = { fg = "fg0" },
					TSDefinitionUsage = { bg = "bg2" },
				},
			},
		},
	},
	{
		"echasnovski/mini.statusline",
		priority = 900,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			content = {
				active = function()
					local statusline = require("mini.statusline")

					local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
					local git = statusline.section_git({ trunc_width = 75 })
					local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
					local filename = statusline.section_filename({ trunc_width = 140 })
					local location = statusline.section_location({ trunc_width = 75 })
					local search = statusline.section_searchcount({ trunc_width = 75 })

					return statusline.combine_groups({
						{ hl = mode_hl, strings = { mode } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
						"%<", -- Mark general truncate point
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=", -- End left alignment
						{ hl = mode_hl, strings = { search, location } },
					})
				end,
			},
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

---@type LazySpec[]
local completion = {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		keys = {
			{
				"<tab>",
				function()
					return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
				end,
				expr = true,
				silent = true,
				mode = "i",
			},
			{
				"<tab>",
				function()
					require("luasnip").jump(1)
				end,
				mode = "s",
			},
			{
				"<s-tab>",
				function()
					require("luasnip").jump(-1)
				end,
				mode = { "i", "s" },
			},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-g>"] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
				}, {
					{ name = "buffer" },
				}),
				enabled = function()
					-- disable completion in comments
					-- keep command mode completion enabled when cursor is in a comment
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					end

					local ctx = require("cmp.config.context")
					return not ctx.in_treesitter_capture("comment") and not ctx.in_syntax_group("Comment")
				end,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "buffer", max_item_count = 15 },
				}),
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline", max_item_count = 15 },
				}),
			})
		end,
	},
}

---@type LazySpec[]
local treesitter = {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		build = ":TSUpdate",
		event = "VeryLazy",
		main = "nvim-treesitter.configs",
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			auto_install = true,

			highlight = { enable = true },
			refactor = {
				highlight_definitions = {
					enable = true,
					clear_on_cursor_move = true,
				},
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
						["as"] = "@scope",
					},
				},
			},
			autotag = { enable = true },
		},
	},
}

---@type LazySpec[]
local lsp = {
	{ "neovim/nvim-lspconfig", lazy = true },
	{ "folke/neodev.nvim", filetypes = { "lua", "vim" }, opts = {} },
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
				"ruff",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		config = function()
			local servers = {
				taplo = {},
				html = {},
				pyright = {
					before_init = function(_, config)
						local path = require("lspconfig/util").path

						local function get_python_path(workspace)
							-- Use activated virtualenv.
							if vim.env.VIRTUAL_ENV then
								return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
							end

							-- Find and use virtualenv in workspace directory.
							for _, pattern in ipairs({ "*", ".*" }) do
								local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
								if match ~= "" then
									return path.join(path.dirname(match), "bin", "python")
								end
							end

							-- Fallback to system Python.
							return exepath("python3") or exepath("python") or "python"
						end

						config.settings.python.pythonPath = get_python_path(config.root_dir)
					end,
				},
				ruff_lsp = {
					on_attach = function(client, _)
						client.server_capabilities.hoverprovider = false
					end,
				},
				rust_analyzer = {},
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = { library = { vim.env.VIMRUNTIME } },
						},
					},
				},
				tsserver = {},
				yamlls = {},
				docker_compose_language_service = {},
				dockerls = {},
			}

			local function add_mappings(bufnr)
				local function map(lhs, rhs, desc, mode)
					vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
				end

				local telescope = require("telescope.builtin")

				map("K", vim.lsp.buf.hover, "Hover documentation")
				map("gd", telescope.lsp_definitions, "Go to definition")
				map("gi", telescope.lsp_implementations, "Go to implementation")
				map("gr", telescope.lsp_references, "Go to references")
				map("<leader>ld", telescope.diagnostics, "Open LSP diagnostics")
				map("<leader>la", vim.lsp.buf.code_action, "LSP actions")
				map("<leader>lr", vim.lsp.buf.rename, "LSP rename")
				map("<C-h>", vim.lsp.buf.signature_help, "Hover signature documentation", "i")
			end

			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				handlers = {
					function(server_name)
						local function on_attach(client, bufnr)
							add_mappings(bufnr)
							if servers[server_name].on_attach then
								servers[server_name].on_attach(client, bufnr)
							end
						end

						local server_opts = vim.tbl_deep_extend("force", {
							capabilities = vim.deepcopy(capabilities),
							on_attach = on_attach,
						}, servers[server_name] or {})

						require("lspconfig")[server_name].setup(server_opts)
					end,
				},
			})
		end,
	},
}

---@type LazySpec[]
local coding = {
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
				python = { "ruff" },
				["*"] = { "insert_newline" },
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
	{ "echasnovski/mini.move", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.operators", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
}

---@type LazySpec[]
local integrations = {
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
		"m4xshen/hardtime.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
	},
}

---@type LazySpec[]
return {
	appearance,
	completion,
	treesitter,
	lsp,
	coding,
	integrations,
}
