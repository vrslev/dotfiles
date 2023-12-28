---@type LazySpec[]
local appearance = {
    {
        'projekt0n/github-nvim-theme',
        priority = 1000,
        main = 'github-theme',
        opts = {
            darken = {
                floats = true,
            },
            groups = {
                all = {
                    DiagnosticHint = { fg = "fg0" },
                    TSDefinitionUsage = { bg = "bg2" },
                }
            },
        }
    },
    {
        'echasnovski/mini.statusline',
        priority = 900,
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            content = {
                active = function()
                    local statusline    = require("mini.statusline")

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
            },
        },
    },
    {
        "echasnovski/mini.indentscope",
        event = "VeryLazy",
        opts = {
            draw = {
                delay = 0,
                animation = function() return 0 end,
            },
            mappings = {
                object_scope = '',
                object_scope_with_border = '',
                goto_top = '',
                goto_bottom = '',
            },
            symbol = "│",
        },
    },
}

---@type LazySpec[]
local completion = {
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
            'hrsh7th/cmp-nvim-lsp-signature-help',
            "saadparwaiz1/cmp_luasnip",
        },
        opts = function()
            local cmp = require('cmp')
            cmp.setup({
                completion = { completeopt = 'menu,menuone,noinsert' },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-g'] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" },
                }, {
                    { name = 'buffer' },
                }),
                enabled = function()
                    -- disable completion in comments
                    -- keep command mode completion enabled when cursor is in a comment
                    if vim.api.nvim_get_mode().mode == 'c' then
                        return true
                    end

                    local ctx = require("cmp.config.context")
                    return not ctx.in_treesitter_capture("comment")
                        and not ctx.in_syntax_group("Comment")
                end,
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'buffer', max_item_count = 15 },
                }),
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' },
                }, {
                    { name = 'cmdline', max_item_count = 15 },
                }),
            })
        end
    },
}

---@type LazySpec[]
local treesitter = {
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            "windwp/nvim-ts-autotag",
        },
        build = ':TSUpdate',
        event = "VeryLazy",
        main = 'nvim-treesitter.configs',
        ---@type TSConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
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

            autotag = {
                enable = true,
            },
        }
    },
}

---@type LazySpec[]
local lsp = {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            "folke/neodev.nvim",
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
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local function default_handler(server)
                lspconfig[server].setup({ capabilities = capabilities })
            end
            local function lua_ls_setup()
                require("neodev").setup()
                lspconfig.lua_ls.setup({
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' }, },
                            workspace = { library = { vim.env.VIMRUNTIME } }
                        }
                    }
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
                    default_handler,
                    lua_ls = lua_ls_setup,
                },
            })
        end
    },
}

---@type LazySpec[]
local coding = {
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
}

---@type LazySpec[]
local integrations = {
    { "lewis6991/gitsigns.nvim", event = "VeryLazy",         opts = {} },
    { "tpope/vim-fugitive",      cmd = { "G", "Git" } },
    { "sontungexpt/url-open",    cmd = "URLOpenUnderCursor", opts = {} },
    { "folke/which-key.nvim",    event = "VeryLazy",         opts = {} },
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", function()
                require("telescope.builtin").find_files({
                    cwd = require("telescope.utils").buffer_dir()
                })
            end },
            { "<leader>fg", "<Cmd>Telescope git_files<CR>" },
            { "<leader>fb", "<Cmd>Telescope buffers<CR>" },
        },
    }
}

---@type LazySpec[]
return {
    appearance,
    completion,
    treesitter,
    lsp,
    coding,
    integrations,
}
