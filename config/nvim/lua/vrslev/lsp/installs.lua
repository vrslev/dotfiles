local lsp_configs = {
    html = {},
    pyright = {},
    rust_analyzer = {},
    sumneko_lua = {
        single_file_support = true,
        settings = {
            Lua = {
                telemetry = {enable = false},
                runtime = {
                    version = 'LuaJIT',
                    path = (function() 
                        local path = vim.split(package.path, ';')
                        table.insert(path, 'lua/?.lua')
                        table.insert(path, 'lua/?/init.lua')
                        return path
                    end)()
                },
                diagnostics = {
                    globals = {'vim'},
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true)
                },
            },
        },
    },
    taplo = {},
    tsserver = {},
}

local mason_tools = {
    "black",
    "isort",
    "prettier",
}

local null_ls = require('null-ls')
local null_ls_configs = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort.with {
        extra_args = { "--profile", "black" },
    },
    null_ls.builtins.formatting.prettier,
}

return {
    lsp_configs = lsp_configs,
    mason_tools = mason_tools,
    null_ls_configs = null_ls_configs
}