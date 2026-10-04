vim.keymap.set("n", "<C-s>", function()
  local autoformat = vim.b.autoformat
  vim.b.autoformat = false
  vim.cmd("write")
  vim.b.autoformat = autoformat
end, { desc = "Save without format" })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>sq", "<C-w>q", { desc = "Close split" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
vim.keymap.set("n", "<leader>m", "<cmd>Maven<cr>", { desc = "Maven" })
vim.keymap.set("n", "<leader>jp", "<cmd>JdtProfile<cr>", { desc = "Switch Maven profile" })
