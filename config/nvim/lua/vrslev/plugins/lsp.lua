---@type LazySpec[]
return {
	{ "neovim/nvim-lspconfig", lazy = true },
	{
		"folke/neodev.nvim",
		filetypes = { "lua", "vim" },
		opts = {
			override = function(_, library)
				library.enabled = true
				library.plugins = true
			end,
		},
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
				"ruff",
				"prettierd",
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
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				tsserver = {},
				yamlls = {},
				docker_compose_language_service = {},
				dockerls = {},
				jsonls = {},
				cssls = {},
			}

			local function add_mappings(bufnr)
				local function map(lhs, rhs, desc, mode)
					vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
				end

				local telescope = require("telescope.builtin")

				map("K", vim.lsp.buf.hover, "Hover documentation")
				map("gd", telescope.lsp_definitions, "Go to definition")
				map("gi", telescope.lsp_implementations, "Go to implementation")
				map("gr", function()
					require("trouble").toggle("lsp_references")
				end, "Go to references")
				map("<leader>ld", function()
					require("trouble").toggle("document_diagnostics")
				end, "Open document diagnostics")
				map("<leader>lw", function()
					require("trouble").toggle("workspace_diagnostics")
				end, "Open workspace diagnostics")
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
