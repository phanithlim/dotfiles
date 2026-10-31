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

require("config.java_tasks").setup()
vim.keymap.set({ "n", "t" }, "<C-/>", function() require("config.terminal_panel").toggle() end, { desc = "Terminal panel" })
vim.keymap.set({ "n", "t" }, "<C-_>", function() require("config.terminal_panel").toggle() end, { desc = "which_key_ignore" })
