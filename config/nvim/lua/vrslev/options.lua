--vim.o.guicursor = ""
vim.o.nu = true
vim.o.modeline = true

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = false

vim.o.hlsearch = false

vim.o.termguicolors = true

vim.o.updatetime = 50

vim.g.mapleader = " "

vim.o.swapfile = true
vim.o.undofile = true

vim.o.ignorecase = true

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "<buffer>",
    callback = vim.lsp.buf.formatting_sync,
})

-- Add borders to windows
vim.lsp.handlers['textDoclument/hover'] = vim.lsp.with(
    -- TODO: Doesn't work
    vim.lsp.handlers.hover,
    {border = 'rounded'}
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = 'rounded'}
)
