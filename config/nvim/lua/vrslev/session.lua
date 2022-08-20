require("auto-session").setup {
    log_level = "error",
    cwd_change_handling = {
        post_cwd_changed_hook = function()
          require("lualine").refresh() 
        end,
      },
}
