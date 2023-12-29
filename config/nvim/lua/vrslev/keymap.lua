vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set({ "n", "v" }, "<leader>y", [["*y]], { desc = "Yank into clipboard" })
vim.keymap.set("n", "<leader>Y", [["*Y]], { desc = "Yank into clipboard linewise" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["*p]], { desc = "Put clipboard after the cursor" })
vim.keymap.set("n", "<leader>P", [["*P]], { desc = "Put clipboard before the cursor" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Prune text" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<leader>sv", vim.cmd.Explore, { desc = "Open netrw" })
