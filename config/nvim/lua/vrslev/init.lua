pcall(require, "impatient")
local bootstrapping = require("vrslev.packer")

if not bootstrapping then
    require("vrslev.options")
    require("vrslev.theme")
    require("vrslev.statusline")
    require("vrslev.cmp")
    require("vrslev.lsp")
    require("vrslev.telescope")
    require("vrslev.treesitter")
    require("vrslev.filetree")
end
