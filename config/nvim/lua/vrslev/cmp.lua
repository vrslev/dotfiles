vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
require('luasnip.loaders.from_vscode').lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require('lspkind')

local select_opts = {behavior = cmp.SelectBehavior.Select}

local mapping = {
    -- Scroll text in the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- Confirm and abort completion
    ['<CR>'] = cmp.mapping.confirm({select = true}),
    ['<C-e>'] = cmp.mapping.abort(),

    -- Autocomplete or select with tab
    ['<Tab>'] = cmp.mapping(function(fallback)
        local col = vim.fn.col('.') - 1
      
        if cmp.visible() then
          cmp.select_next_item(select_opts)
        elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
          fallback()
        else
          cmp.complete()
        end
      end, {'i', 's'}),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item(select_opts)
        else
          fallback()
        end
      end, {'i', 's'}),
}

local sources = {
    {name = 'nvim_lsp', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
    {name = 'path'},
    { name = 'nvim_lua' },
}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    formatting = {
        fields = {'menu', 'abbr', 'kind'},
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
        })
    },
    mapping = mapping,
    sources = sources,
    window = {
        documentation = cmp.config.window.bordered(),
    },
    experimental = {ghost_text = true},
}