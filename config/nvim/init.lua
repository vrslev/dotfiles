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
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])
vim.keymap.set("n", "<leader>P", [["+P]])

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
                "hrsh7th/cmp-cmdline",
                'hrsh7th/cmp-path',
                'hrsh7th/nvim-cmp',
                'L3MON4D3/LuaSnip',
                'folke/neodev.nvim',
                "ray-x/lsp_signature.nvim"
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

                require('lsp_signature').setup()

                local cmp = require('cmp')
                local cmp_action = require('lsp-zero').cmp_action()

                cmp.setup({
                    sources = {
                        {
                            name = "nvim_lsp",
                            entry_filter = function(entry, ctx)
                                local types = require("cmp.types")
                                local kind = types.lsp.CompletionItemKind[entry:get_kind()]
                                return kind ~= "Text"
                            end
                        }
                    },

                    enabled = function()
                        -- disable completion in comments
                        local context = require 'cmp.config.context'
                        -- keep command mode completion enabled when cursor is in a comment
                        if vim.api.nvim_get_mode().mode == 'c' then
                            return true
                        else
                            return not context.in_treesitter_capture("comment")
                                and not context.in_syntax_group("Comment")
                        end
                    end,
                    preselect = 'item',
                    completion = {
                        completeopt = 'menu,menuone,noinsert'
                    },
                    mapping = cmp.mapping.preset.insert({
                        -- `Enter` key to confirm completion
                        ['<CR>'] = cmp.mapping.confirm({ select = false }),

                        -- Ctrl+Space to trigger completion menu
                        ['<C-Space>'] = cmp.mapping.complete(),

                        -- Navigate between snippet placeholder
                        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                        ['<C-b>'] = cmp_action.luasnip_jump_backward(),

                        -- Scroll up and down in the completion documentation
                        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    })
                })
                cmp.setup.cmdline({ '/', '?' }, {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = 'buffer' }
                    }
                })
                cmp.setup.cmdline(':', {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = 'path' }
                    }, {
                        { name = 'cmdline' }
                    })
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
