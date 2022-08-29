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

vim.cmd "set noshowmode"
vim.cmd "set shm+=I"

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

vim.o.cursorline = true

vim.o.splitright = true
vim.o.splitbelow = true

local arrow_keys = { "<Up>", "<Left>", "<Right>", "<Down>" }
for _, key in pairs(arrow_keys) do
    vim.cmd("noremap " .. key .. " <Nop>")
end

-- Move around buffers
vim.keymap.set("n", "<leader>n", "<cmd>bn<cr>")
vim.keymap.set("n", "<leader>p", "<cmd>bp<cr>")
vim.keymap.set("n", "<leader>d", "<cmd>bd<cr>")
