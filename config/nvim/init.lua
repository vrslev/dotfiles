vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Sane defaults, see https://github.com/neovim/neovim/issues/21342
vim.o.termguicolors = true
vim.o.number = true
vim.o.expandtab = true

-- Sensible, but opinionated
vim.o.hlsearch = false
vim.o.cursorline = true
vim.o.signcolumn = 'yes'

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.undofile = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.completeopt = 'menuone,noselect'

vim.o.scrolloff = 10
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.o.breakindent = true

vim.o.spell = true

for _, mode in pairs({ 'n', 'i', 'v', 'x' }) do
    for _, key in pairs({ '<Up>', '<Down>', '<Left>', '<Right>' }) do
        vim.keymap.set(mode, key, '<Nop>')
    end
end

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

vim.keymap.set("n", "<leader>pv", vim.cmd.Explore)

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>u", vim.cmd.URLOpenUnderCursor)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local theme = vim.env.DARK_MODE and "github_dark_default" or "github_light_default"

require("lazy").setup({
        {
            'projekt0n/github-nvim-theme',
            lazy = false,
            priority = 1000,
            config = function()
                require('github-theme').setup()
                vim.cmd.colorscheme(theme)
            end,
        },
        { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>pf', builtin.find_files)
            end
        },
        {
            'VonHeikemen/lsp-zero.nvim',
            branch = 'v3.x',
            dependencies = {
                'williamboman/mason.nvim',
                'williamboman/mason-lspconfig.nvim',
                'neovim/nvim-lspconfig',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/nvim-cmp',
                'L3MON4D3/LuaSnip',
                'folke/neodev.nvim',
            },
            config = function()
                require('neodev').setup()

                local lsp_zero = require('lsp-zero')

                lsp_zero.on_attach(function(client, bufnr)
                    local opts = { buffer = bufnr }

                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                end)

                lsp_zero.format_on_save({
                    format_opts = {
                        async = false,
                        timeout_ms = 10000,
                    },
                    servers = {
                        ['taplo'] = { 'toml' },
                        ['html'] = { 'html' },
                        ['ruff_lsp'] = { 'python' },
                        ['yamlls'] = { 'yaml' },
                        ['tsserver'] = { 'javascript', 'typescript' },
                        ['rust_analyzer'] = { 'rust' },
                        ['lua_ls'] = { 'lua' },
                    }
                })

                require('mason').setup({})
                require('mason-lspconfig').setup({
                    ensure_installed = {
                        'taplo',
                        'html',
                        'pyright',
                        'ruff_lsp',
                        'rust_analyzer',
                        'lua_ls',
                        'tsserver',
                        'yamlls',
                    },
                    handlers = {
                        lsp_zero.default_setup,
                        lua_ls = function()
                            local lua_opts = lsp_zero.nvim_lua_ls()
                            require('lspconfig').lua_ls.setup(lua_opts)
                        end,
                    },
                })
            end
        },
        { "lukas-reineke/indent-blankline.nvim", config = function() require("ibl").setup({ indent = { char = "│" } }) end },
        {
            "sontungexpt/url-open",
            event = "VeryLazy",
            cmd = "URLOpenUnderCursor",
            opts = {}
            -- config = function()
            --     require("url-open").setup()
            -- end,
        },
    },
    { install = { colorscheme = { theme, "habamax" } } }
)

-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        sync_install = false,
        auto_install = true,
        ignore_install = {},

        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    }
end, 0)
