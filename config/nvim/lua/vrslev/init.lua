require("vrslev.options")
require("vrslev.keymap")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local theme = vim.env.DARK_MODE and "github_dark_dimmed" or "github_light"

require("lazy").setup("vrslev.plugins", {
    install = {
        colorscheme = { theme, "habamax" },
    },
    change_detection = {
        notify = false,
    },
})
vim.cmd.colorscheme(theme)
