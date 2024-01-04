vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	callback = function()
		if not vim.bo.readonly and vim.fn.expand("%") ~= "" then
			vim.cmd("silent update")
		end
	end,
})
