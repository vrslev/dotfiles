local lsp_configs = {
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
                    path = (function()
                        local path = vim.split(package.path, ';')
                        table.insert(path, 'lua/?.lua')
                        table.insert(path, 'lua/?/init.lua')
                        return path
                    end)()
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
    tsserver = {},
}

local mason_tools = {
    "black",
    "isort",
    "prettier",
}

local null_ls = require('null-ls')
local null_ls_configs = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort.with {
        extra_args = { "--profile", "black" },
    },
    null_ls.builtins.formatting.prettier,
}

-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/

local telescope_builtin = require("telescope.builtin")
local lspactions = require("lspactions")

local function format_cmd(cmd)
    return ("<cmd>%s<cr>"):format(cmd)
end

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

    { 'n', '<leader>t', format_cmd('Trouble')},
}

local function setup_keybindings()
    local opts = { buffer = true }

    for _, item in pairs(keybindings) do
        local mode, lhs, rhs = item[1], item[2], item[3]
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

local shared_lspconfig = {
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = require('cmp_nvim_lsp').update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    ),
    on_attach = function()
        setup_keybindings()
    end
}


return {
    mason_tools = mason_tools,
    shared_lspconfig = shared_lspconfig,
    lsp_configs = lsp_configs,
    null_ls_configs = null_ls_configs,
}
