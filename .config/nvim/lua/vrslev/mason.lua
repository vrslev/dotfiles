require("mason").setup {}

local required_servers = {
    "pyright",
    "rust_analyzer",
    "sumneko_lua",
    "tsserver"
}

require("mason-lspconfig").setup {
    ensure_installed = required_servers,
    automatic_installation = true
}
