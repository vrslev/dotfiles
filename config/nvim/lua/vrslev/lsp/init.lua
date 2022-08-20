local config = require("vrslev.lsp.config")

require("mason").setup()
require("mason-lspconfig").setup {
    automatic_installation = true
}
require("mason-tool-installer").setup {
    ensure_installed = config.mason_tools
}

local lspconfig = require('lspconfig')
lspconfig.util.default_config = vim.tbl_deep_extend(
    'force',
    lspconfig.util.default_config,
    config.shared_lspconfig
)
for server_name, server_config in pairs(config.lsp_configs) do
    lspconfig[server_name].setup(server_config)
end

require('null-ls').setup {
    sources = config.null_ls_configs
}

require("lsp_signature").setup {
    hint_prefix = ""
}

require("trouble").setup()
 
require("fidget").setup()
