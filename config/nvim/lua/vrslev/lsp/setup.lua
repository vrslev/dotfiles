local lspconfig = require('lspconfig')
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")
local null_ls = require('null-ls')

local function extend_shared_lspconfig(config)
  lspconfig.util.default_config = vim.tbl_deep_extend(
    'force',
    lspconfig.util.default_config,
    config
  )
end

local function install_servers_and_tools(tools)
  mason.setup()
  mason_lspconfig.setup {
      automatic_installation = true
  }
  mason_tool_installer.setup {
    ensure_installed = tools
  }

end

local function setup_servers(servers)
  for server_name, server_config in pairs(servers) do
    lspconfig[server_name].setup(server_config)
  end
end

local function setup_null_ls(sources)
  null_ls.setup {
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort.with {
            extra_args = { "--profile", "black" },
        },
        null_ls.builtins.formatting.prettier,
    },
}
end

return function(shared_lspconfig, installs)
  extend_shared_lspconfig(shared_lspconfig)
  install_servers_and_tools(installs.mason_tools)
  setup_servers(installs.lsp_configs)
  setup_null_ls(installs.null_ls_configs)
end