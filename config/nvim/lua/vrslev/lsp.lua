require("mason").setup()
require('mason-lspconfig').setup {
    automatic_installation = true
}
require("mason-tool-installer").setup {
    ensure_installed = {
        "black",
        "isort",
        "prettier",
    },
}

local lspconfig = require('lspconfig')
local telescope_builtin = require("telescope.builtin")
local lspactions = require("lspactions")

local keybindings = {
    -- Displays hover information about the symbol under the cursor
    { 'n', 'K', vim.lsp.buf.hover },

    -- Jump to the definition
    { 'n', 'gd', telescope_builtin.lsp_definitions },

    -- Jump to declaration
    { 'n', 'gD', vim.lsp.buf.declaration },

    -- Lists all the implementations for the symbol under the cursor
    { 'n', 'gi', telescope_builtin.lsp_implementations },

    -- Jumps to the definition of the type symbol
    { 'n', 'gt', telescope_builtin.lsp_type_definitions },

    -- Lists all the references
    { 'n', 'gr', telescope_builtin.lsp_references },

    -- Displays a function's signature information
    { 'n', '<C-k>', vim.lsp.buf.signature_help },

    -- Renames all references to the symbol under the cursor
    { 'n', '<F2>', lspactions.rename },

    -- Selects a code action available at the current cursor position
    { 'n', '<F4>', lspactions.code_action },
    { 'x', '<F4>', lspactions.range_code_action },

    -- Show diagnostics in a floating window
    { 'n', 'gl', lspactions.diagnostic.show_line_diagnostics },

    -- Move to the previous diagnostic
    { 'n', '[d', lspactions.diagnostic.goto_prev },

    -- Move to the next diagnostic
    { 'n', ']d', lspactions.diagnostic.goto_next },

    { 'n', '<leader>t', require("trouble").open },
}

local function setup_keybindings()
    local opts = { buffer = true }

    for _, item in pairs(keybindings) do
        vim.keymap.set(item[1], item[2], item[3], opts)
    end
end

lspconfig.util.default_config = vim.tbl_deep_extend(
    'force',
    lspconfig.util.default_config,
    {
        capabilities = require('cmp_nvim_lsp').update_capabilities(
            vim.lsp.protocol.make_client_capabilities()
        ),
        on_attach = function()
            setup_keybindings()
        end,
    }
)

local function setup_servers(servers)
    for server_name, server_config in pairs(servers) do
        lspconfig[server_name].setup(server_config)
    end
end

setup_servers {
    html = {},
    pyright = {},
    rust_analyzer = {},
    sumneko_lua = {
        single_file_support = true,
        settings = {
            Lua = {
                telemetry = { enable = false },
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true)
                },
            },
        },
    },
    taplo = {},
}

local null_ls = require('null-ls')
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort.with {
            extra_args = { "--profile", "black" },
        },
        null_ls.builtins.formatting.prettier,
    },
}

require("lsp_signature").setup {
    hint_prefix = ""
}

require("trouble").setup()

require("fidget").setup()
