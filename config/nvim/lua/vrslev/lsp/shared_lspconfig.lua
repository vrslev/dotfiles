-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/

local keybindings = {
    -- Displays hover information about the symbol under the cursor
    {'n', 'K', 'vim.lsp.buf.hover'},

    -- Jump to the definition
    {'n', 'gd', 'vim.lsp.buf.definition'},

    -- Jump to declaration
    {'n', 'gD', 'lua vim.lsp.buf.declaration'},

    -- Lists all the implementations for the symbol under the cursor
    {'n', 'gi', 'vim.lsp.buf.implementation'},

    -- Jumps to the definition of the type symbol
    {'n', 'go', 'lua vim.lsp.buf.type_definition'},

    -- Lists all the references 
    {'n', 'gr', 'vim.lsp.buf.references'},

    -- Displays a function's signature information
    {'n', 'go', 'vim.lsp.buf.type_definition'},

    -- Displays a function's signature information
    {'n', '<C-k>', 'vim.lsp.buf.signature_help'},

    -- Renames all references to the symbol under the cursor
    {'n', '<F2>', 'vim.lsp.buf.rename'},

    -- Selects a code action available at the current cursor position
    {'n', '<F4>', 'lua vim.lsp.buf.code_action'},
    {'x', '<F4>', 'vim.lsp.buf.range_code_action'},

    -- Show diagnostics in a floating window
    {'n', 'gl', 'vim.diagnostic.open_float'},

    -- Move to the previous diagnostic
    {'n', '[d', 'vim.diagnostic.goto_prev'},

    -- Move to the next diagnostic
    {'n', ']d', 'vim.diagnostic.goto_next'},
}

local function setup_keybindings()
    local opts = {buffer = true}
    
    for _, item in pairs(keybindings) do
        local mode, lhs, rhs = item[1], item[2], ("<cmd>lua %s()<cr>"):format(item[3])
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

return {
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = require('cmp_nvim_lsp').update_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    ),
    on_attach = setup_keybindings
}
