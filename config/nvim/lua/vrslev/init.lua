pcall(require, "impatient")

require("vrslev.options")

local bootstrapping = require("vrslev.packer")

if not bootstrapping then
    require("vrslev.theme")
    require("vrslev.cmp")
    require("vrslev.lsp")
    require("vrslev.treesitter")
end
