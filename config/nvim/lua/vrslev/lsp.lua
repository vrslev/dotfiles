require('lsp-setup').setup {
    mappings = {
        gd = 'lua require("telescope.builtin").lsp_definitions()',
        gD = 'lua vim.lsp.buf.declaration()',
        gi = 'lua require("telescope.builtin").lsp_implementations()',
        gl = 'lua require("lspactions").diagnostic.show_line_diagnostics()',
        gr = 'lua require("telescope.builtin").lsp_references()',
        gt = 'lua require("telescope.builtin").lsp_type_definitions()',
        K = 'lua vim.lsp.buf.hover()',
        ['<C-k>'] = 'lua vim.lsp.buf.signature_help()',
        ['<F2>'] = 'lua require("lspactions").rename()',
        ['<F4>'] = 'lua require("lspactions").code_action()',
        ['<space>t'] = 'lua require("trouble").open()',
        ['[d'] = 'lua require("lspactions").diagnostic.goto_prev()',
        [']d'] = 'lua require("lspactions").diagnostic.goto_next()',
    },
    servers = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
        html = {},
        pyright = {},
        rust_analyzer = {},
        sumneko_lua = require("lua-dev").setup(),
        taplo = {},
    },
}

require("mason-tool-installer").setup {
    ensure_installed = {
        "black",
        "isort",
        "prettier",
    },
}

local null_ls = require('null-ls')
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort.with {
            extra_args = { "--profile", "black" },
        },
        null_ls.builtins.formatting.prettier,
    },
}

require("lsp_signature").setup {
    hint_prefix = ""
}

require("trouble").setup()

require("fidget").setup()
