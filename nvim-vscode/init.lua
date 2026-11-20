-- Neovim inside VS Code (vscode-neovim, NVIM_APPNAME=nvim-vscode): your LazyVim keys, done by VS Code
if not vim.g.vscode then
  return
end

local vscode = require("vscode")

vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true

local function action(name)
  return function() vscode.action(name) end
end

local map = vim.keymap.set

-- find
map("n", "<leader><space>", action("workbench.action.quickOpen"), { desc = "Find file" })
map("n", "<leader>ff", action("workbench.action.quickOpen"), { desc = "Find file" })
map("n", "<leader>fr", action("workbench.action.openRecent"), { desc = "Recent" })
map("n", "<leader>fj", action("workbench.action.showAllSymbols"), { desc = "Find class" })
map("n", "<leader>/", action("workbench.action.findInFiles"), { desc = "Find text" })
map("n", "<leader>sg", action("workbench.action.findInFiles"), { desc = "Find text" })
map("n", "<leader>ss", action("workbench.action.gotoSymbol"), { desc = "Symbols in file" })

-- files and buffers
map("n", "<leader>e", action("workbench.view.explorer"), { desc = "Explorer" })
map("n", "-", action("workbench.files.action.showActiveFileInExplorer"), { desc = "Show file in explorer" })
map("n", "<S-h>", action("workbench.action.previousEditor"), { desc = "Previous file" })
map("n", "<S-l>", action("workbench.action.nextEditor"), { desc = "Next file" })
map("n", "<Tab>", action("workbench.action.nextEditor"), { desc = "Next file" })
map("n", "<S-Tab>", action("workbench.action.previousEditor"), { desc = "Previous file" })
map("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "Close file" })
map("n", "<C-s>", action("workbench.action.files.saveWithoutFormatting"), { desc = "Save without format" })

-- splits
map("n", "<leader>sv", action("workbench.action.splitEditorRight"), { desc = "Split vertical" })
map("n", "<leader>sh", action("workbench.action.splitEditorDown"), { desc = "Split horizontal" })
map("n", "<leader>sq", action("workbench.action.closeActiveEditor"), { desc = "Close split" })
map("n", "<leader>se", action("workbench.action.evenEditorWidths"), { desc = "Equalize splits" })
map("n", "<C-h>", action("workbench.action.navigateLeft"), { desc = "Go left" })
map("n", "<C-j>", action("workbench.action.navigateDown"), { desc = "Go down" })
map("n", "<C-k>", action("workbench.action.navigateUp"), { desc = "Go up" })
map("n", "<C-l>", action("workbench.action.navigateRight"), { desc = "Go right" })

-- code
map("n", "gr", action("editor.action.goToReferences"), { desc = "References" })
map("n", "gI", action("editor.action.goToImplementation"), { desc = "Implementation" })
map("n", "<leader>ca", action("editor.action.quickFix"), { desc = "Code action" })
map("n", "<leader>cr", action("editor.action.rename"), { desc = "Rename" })
map({ "n", "x" }, "<leader>cf", action("editor.action.formatDocument"), { desc = "Format" })
map("n", "]d", action("editor.action.marker.next"), { desc = "Next problem" })
map("n", "[d", action("editor.action.marker.prev"), { desc = "Previous problem" })
map("n", "<leader>xx", action("workbench.actions.view.problems"), { desc = "Problems" })

-- git
map("n", "<leader>gg", action("workbench.view.scm"), { desc = "Git" })
map("n", "]h", action("workbench.action.editor.nextChange"), { desc = "Next change" })
map("n", "[h", action("workbench.action.editor.previousChange"), { desc = "Previous change" })

map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})
