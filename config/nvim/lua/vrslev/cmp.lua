local cmp = require("cmp")
local cmp_context = require("cmp.config.context")

local mapping = {
    -- Scroll text in the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- Confirm and abort completion
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-e>'] = cmp.mapping.abort(),

    -- Autocomplete or select with tab
    ['<Tab>'] = cmp.mapping(function(fallback)
        local col = vim.fn.col('.') - 1

        if cmp.visible() then
            cmp.select_next_item()
        elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
            fallback()
        else
            cmp.complete()
        end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        else
            fallback()
        end
    end, { 'i', 's' }),
}

local sources = {
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2, max_item_count = 5 },
    { name = 'path' },
    { name = 'nvim_lua' },
}

-- https://github.com/lukas-reineke/cmp-under-comparator/blob/6857f10272c3cfe930cece2afa2406e1385bfef8/lua/cmp-under-comparator/init.lua
local function under(entry1, entry2)
    local _, entry1_under = entry1.completion_item.label:find "^_+"
    local _, entry2_under = entry2.completion_item.label:find "^_+"
    entry1_under = entry1_under or 0
    entry2_under = entry2_under or 0
    if entry1_under > entry2_under then
        return false
    elseif entry1_under < entry2_under then
        return true
    end
end

local comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    cmp.config.compare.score,
    under,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
}

cmp.setup {
    enabled = function()
        if vim.api.nvim_get_mode().mode == 'c' then
            return true
        end

        return not cmp_context.in_treesitter_capture("comment")
            and not cmp_context.in_syntax_group("Comment")
    end,
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    },
    formatting = {
        fields = { 'menu', 'abbr', 'kind' },
        format = require('lspkind').cmp_format({
            mode = 'symbol_text',
            maxwidth = 50,
        })
    },
    mapping = mapping,
    sources = sources,
    sorting = { comparators = comparators },
    window = {
        documentation = cmp.config.window.bordered(),
    },
    experimental = { ghost_text = true },
}


-- `/` cmdline setup.
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
