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

-- Shift + mouse wheel scrolls sideways, like a browser
vim.keymap.set({ "n", "v", "i" }, "<S-ScrollWheelDown>", "<ScrollWheelRight>", { desc = "Scroll right" })
vim.keymap.set({ "n", "v", "i" }, "<S-ScrollWheelUp>", "<ScrollWheelLeft>", { desc = "Scroll left" })

require("java.tasks").setup()
require("ui.icon_themes").setup()
vim.keymap.set({ "n", "t" }, "<C-/>", function() require("ui.terminal_panel").toggle() end, { desc = "Terminal panel" })
vim.keymap.set({ "n", "t" }, "<C-_>", function() require("ui.terminal_panel").toggle() end, { desc = "which_key_ignore" })
