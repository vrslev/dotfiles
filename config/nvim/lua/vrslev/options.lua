--
-- Sane defaults, see https://github.com/neovim/neovim/issues/21342
--

-- Appearance
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.title = true

vim.o.wrap = false
vim.o.hlsearch = false

vim.o.splitright = true
vim.o.splitbelow = true

-- Behavior
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.undofile = true


--
-- Personal preferences
--
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Appearance
vim.o.cursorline = true
vim.o.spell = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

vim.o.cmdheight = 0
vim.o.showcmd = false
vim.o.showmode = false

vim.opt.shortmess:append({ I = true, W = true })

-- Behavior
vim.o.virtualedit = "block"
vim.o.inccommand = "split"
