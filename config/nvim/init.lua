-- Inspired by:
-- https://github.com/ThePrimeagen/init.lua
-- https://github.com/LazyVim/LazyVim
-- https://github.com/nvim-lua/kickstart.nvim

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
vim.o.completeopt = 'menu,menuone,noinsert'

for _, mode in pairs({ 'n', 'i', 'v', 'x' }) do
    for _, key in pairs({ '<Up>', '<Down>', '<Left>', '<Right>' }) do
        vim.keymap.set(mode, key, '<Nop>')
    end
end

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

vim.keymap.set("n", "<leader>fv", vim.cmd.Explore)


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

local theme = vim.env.DARK_MODE and "github_dark_dimmed" or "github_light"
local lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }
local lazyfile_and_verylazy = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" }

require("lazy").setup({
        -- Appearance
        {
            'projekt0n/github-nvim-theme',
            priority = 1000,
            config = function()
                require('github-theme').setup({
                    darken = {
                        floats = true,
                    },
                    groups = {
                        all = {
                            DiagnosticHint = { fg = "fg0" },
                            TSDefinitionUsage = { bg = "bg2" },
                        }
                    },
                })
                vim.cmd.colorscheme(theme)
            end,
        },
        {
            'echasnovski/mini.statusline',
            priority = 900,
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                local statusline = require("mini.statusline")

                local function active()
                    local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
                    local git           = statusline.section_git({ trunc_width = 75 })
                    local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
                    local filename      = statusline.section_filename({ trunc_width = 140 })
                    local location      = statusline.section_location({ trunc_width = 75 })
                    local search        = statusline.section_searchcount({ trunc_width = 75 })

                    return statusline.combine_groups({
                        { hl = mode_hl,                 strings = { mode } },
                        { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineFilename', strings = { filename } },
                        '%=', -- End left alignment
                        { hl = mode_hl,                  strings = { search, location } },
                    })
                end

                statusline.setup({ content = { active = active } })
            end
        },
        {
            "echasnovski/mini.indentscope",
            event = lazyfile,
            config = function()
                require('mini.indentscope').setup({
                    draw = {
                        delay = 0,
                        animation = require('mini.indentscope').gen_animation.none(),
                    },
                    mappings = {
                        object_scope = '',
                        object_scope_with_border = '',
                        goto_top = '',
                        goto_bottom = '',
                    },
                    symbol = "│"
                })
            end
        },
        {
            "lewis6991/gitsigns.nvim",
            event = lazyfile,
            opts = {}
        },

        -- completion
        {
            "L3MON4D3/LuaSnip",
            dependencies = {
                "rafamadriz/friendly-snippets",
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
            keys = {
                {
                    "<tab>",
                    function()
                        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                    end,
                    expr = true,
                    silent = true,
                    mode = "i",
                },
                { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
                { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
            },
        },
        {
            'hrsh7th/nvim-cmp',
            event = { "InsertEnter", "CmdlineEnter" },
            dependencies = {
                'hrsh7th/cmp-nvim-lsp',
                "hrsh7th/cmp-buffer",
                'hrsh7th/cmp-path',
                "hrsh7th/cmp-cmdline",
                "saadparwaiz1/cmp_luasnip",
            },
            opts = function()
                local cmp = require('cmp')

                cmp.setup({
                    mapping = cmp.mapping.preset.insert({
                        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                        { name = "path" },
                    }, {
                        { name = 'buffer' },
                    }),
                    enabled = function()
                        -- disable completion in comments
                        -- keep command mode completion enabled when cursor is in a comment
                        if vim.api.nvim_get_mode().mode == 'c' then
                            return true
                        else
                            return not cmp.config.context.in_treesitter_capture("comment")
                                and not cmp.config.context.in_syntax_group("Comment")
                        end
                    end,
                    snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body)
                        end,
                    },
                })

                cmp.setup.cmdline({ '/', '?' }, {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {
                        { name = 'buffer' }
                    }
                })

                cmp.setup.cmdline(':', {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({ { name = 'path' }
                    }, {
                        { name = 'cmdline' }
                    })
                })
            end
        },
        {
          "ray-x/lsp_signature.nvim",
          event = "VeryLazy",
          opts = {
            bind = false,  -- disable border
            fix_pos = true,
            hint_enable = false,
          }
        },

        -- Treesitter
        {
            'nvim-treesitter/nvim-treesitter',
            dependencies = {
                'nvim-treesitter/nvim-treesitter-refactor',
                'nvim-treesitter/nvim-treesitter-textobjects',
            },
            build = ':TSUpdate',
            event = lazyfile_and_verylazy,
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require('nvim-treesitter.configs').setup {
                    ensure_installed = 'all',
                    auto_install = true,

                    highlight = { enable = true },

                    refactor = {
                        highlight_definitions = {
                            enable = true,
                            clear_on_cursor_move = true,
                        },
                    },

                    textobjects = {
                        select = {
                            enable = true,
                            lookahead = true,
                            keymaps = {
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                ["ac"] = "@class.outer",
                                ["ic"] = "@class.inner",
                                ["as"] = "@scope",
                            },
                        },
                    },
                }
            end
        },
        {
            "windwp/nvim-ts-autotag",
            event = lazyfile,
            opts = {},
        },

        -- LSP and completion
        {
            "neovim/nvim-lspconfig",
            event = lazyfile,
            dependencies = {
                { "folke/neodev.nvim", opts = {} },
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
            },
            config = function()
                vim.api.nvim_create_autocmd('LspAttach', {
                    desc = 'LSP actions',
                    callback = function(event)
                        local opts = { buffer = event.buf }
                        local telescope = require('telescope.builtin')

                        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                        vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
                        vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)
                        vim.keymap.set("n", "gr", telescope.lsp_references, opts)
                        vim.keymap.set("n", "<leader>ld", telescope.diagnostics, opts)
                        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
                        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
                        vim.keymap.set("n", "<leader>lf", vim.lsp.buf.code_action, opts)
                        vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
                        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                    end
                })

                local lspconfig = require('lspconfig')
                local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
                local default_setup = function(server)
                    lspconfig[server].setup({
                        capabilities = lsp_capabilities,
                    })
                end

                require('mason').setup()
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
                        default_setup,
                        lua_ls = function()
                            require("neodev").setup()
                            require('lspconfig').lua_ls.setup({
                                settings = {
                                    Lua = {
                                        runtime = { version = 'LuaJIT' },
                                        diagnostics = { globals = { 'vim' }, },
                                        workspace = { library = { vim.env.VIMRUNTIME } }
                                    }
                                }
                            })
                        end,
                    },
                })
            end
        },

        -- Misc
        {
            'stevearc/conform.nvim',
            event = "VeryLazy",
            config = function()
                require("conform").setup({ format_on_save = { timeout_ms = 10000, lsp_fallback = true } })

                vim.api.nvim_create_autocmd("BufWritePre", {
                    pattern = "*",
                    callback = function(args)
                        require("conform").format({ bufnr = args.buf })
                    end,
                })
            end
        },
        { "echasnovski/mini.comment", event = "VeryLazy", opts = {} },
        {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            config = function()
                require("nvim-autopairs").setup({ check_ts = true })
                require('cmp').event:on(
                  'confirm_done',
                  require('nvim-autopairs.completion.cmp').on_confirm_done()
                )
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' },
            cmd = "Telescope",
            config = function()
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>ff', builtin.find_files)
            end
        },
        { "sontungexpt/url-open", cmd = "URLOpenUnderCursor", opts = {} },
        { "tpope/vim-fugitive", cmd = "Git" },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {},
        },
    },

    { install = { colorscheme = { theme, "habamax" } } }
)
