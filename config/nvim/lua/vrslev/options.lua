vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Sane defaults, see https://github.com/neovim/neovim/issues/21342
vim.o.termguicolors = true
vim.o.number = true
vim.o.expandtab = true
vim.o.signcolumn = 'yes'
vim.o.title = true

-- Sensible, but opinionated
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.hlsearch = false
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- Other
vim.o.cursorline = true
vim.o.spell = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.o.showcmd = false
vim.o.showmode = false
vim.opt.shortmess:append({ I = true })
