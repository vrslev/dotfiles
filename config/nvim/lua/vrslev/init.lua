pcall(require, "impatient")
require("vrslev.options")
local bootstrapping = require("vrslev.packer")

if not bootstrapping then
    require("vrslev.ui")

    require("vrslev.autopairs")
    require("vrslev.cmp")
    require("vrslev.commenter")
    require("vrslev.filetree")
    require("vrslev.fuzzy_finder")
    require("vrslev.lsp")
    require("vrslev.treesitter")
end
