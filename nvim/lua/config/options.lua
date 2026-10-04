require("config.remote_clipboard").setup()
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader Key
vim.g.mapleader = " "

-- Encoding
vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- General UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.list = false
vim.g.snacks_animate = false

-- Minimalist Status/Cmd Line
vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.showcmd = true

-- Search & Patterns
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.wrap = false

-- Splitting Behavior
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

-- System & Files
vim.opt.backup = false
vim.opt.scrolloff = 10
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*" })

-- Wrap vim.notify only after startup: during startup LazyVim swaps in a temporary
-- notify that queues messages, and wrapping that makes its replay loop forever.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local orig_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == "string" and msg:find("Can't set 'path'") then
        return
      end
      orig_notify(msg, level, opts)
    end
  end,
})

-- LazyVim Specifics
vim.g.lazyvim_eslint_auto_format = true
vim.g.lazyvim_prettier_needs_config = false
vim.lsp.commands["setContext"] = function() end

-- "Undefine" goalbe (Setting to nil removes it if it was a global)
vim.g.goalbe = nil

-------------------------------------------------------------------------------
-- Note: If 'goalbe' was a plugin you wanted to disable,
-- you should do that in your lua/plugins/ example.lua instead!
-------------------------------------------------------------------------------
---

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = ".env*",
  callback = function()
    vim.bo.filetype = "sh"
  end,
})

-- Neovide (GUI only)
if vim.g.neovide then
  -- Paste with Ctrl+Shift+V
  vim.keymap.set({ "n", "v" }, "<C-S-v>", '"+P', { desc = "Paste from clipboard" })
  vim.keymap.set({ "i", "c" }, "<C-S-v>", "<C-R>+", { desc = "Paste from clipboard" })
  vim.keymap.set("t", "<C-S-v>", [[<C-\><C-n>"+Pi]], { desc = "Paste from clipboard" })

  -- Zoom with Ctrl+= / Ctrl+- / Ctrl+0
  vim.g.neovide_scale_factor = 1.0
  local function zoom(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function() zoom(1.1) end, { desc = "Zoom in" })
  vim.keymap.set("n", "<C-->", function() zoom(1 / 1.1) end, { desc = "Zoom out" })
  vim.keymap.set("n", "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Reset zoom" })

  -- Same Ctrl-b keys as tmux
  require("config.neovide_prefix").setup()

  -- Subtler animations
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_scroll_animation_length = 0.2
end

-- :terminal fixes: theme colors, and a starship prompt without $fill
-- (the right-aligned prompt garbles when the terminal window is resized)
require("config.terminal_colors").setup()
require("config.terminal_panel").setup()
vim.env.STARSHIP_CONFIG = vim.fn.expand("~/.config/starship-nvim.toml")
