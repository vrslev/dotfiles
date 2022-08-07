--[[
local capabilities = require("cmp_nvim_lsp")
    .update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )

local lspconfig = require("lspconfig")

-- https://github.com/ThePrimeagen/.dotfiles/blob/6a8287fbb400511649da5867dd134074b8ecec52/nvim/.config/nvim/after/plugin/lsp.lua#L89
local function config(_config)
	return vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, _config or {})
end

lspconfig["pyright"].setup(config())

lspconfig["rust_analyzer"].setup(config())

lspconfig["sumneko_lua"].setup(config({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  }
}))

lspconfig["tsserver"].setup(config())
]]--

local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.nvim_workspace()
lsp.ensure_installed({
    "pyright",
    "rust_analyzer",
    "sumneko_lua",
    "tsserver"
})
lsp.setup()

