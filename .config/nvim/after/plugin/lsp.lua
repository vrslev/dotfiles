local capabilities = require("cmp_nvim_lsp")
    .update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
    
local lspconfig = require("lspconfig")
local servers = require("mason-lspconfig").get_installed_servers()

for _, server in pairs(servers) do
    lspconfig[server].setup { capabilities = capabilities }
end
  