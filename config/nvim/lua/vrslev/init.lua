pcall(require, "impatient")
require("vrslev.options")
local bootstrapping = require("vrslev.packer")

if not bootstrapping then
    -- UI module should be loaded after treesitter to adjust rainbow brackets theming
    require("vrslev.treesitter")
    require("vrslev.ui")
    
    require("vrslev.autopairs")
    require("vrslev.cmp")
    require("vrslev.commenter")
    require("vrslev.filetree")
    require("vrslev.fuzzy_finder")
    require("vrslev.lsp")
    require("vrslev.session")
end
