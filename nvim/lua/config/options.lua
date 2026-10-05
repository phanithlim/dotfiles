require("config.remote_clipboard").setup()

vim.g.mapleader = " "

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.list = false
vim.g.snacks_animate = false

vim.opt.cmdheight = 0
vim.opt.laststatus = 0
vim.opt.showcmd = true

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

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

vim.opt.backup = false
vim.opt.scrolloff = 10
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*" })

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

vim.filetype.add({
  pattern = {
    ["Jenkinsfile[._-].*"] = "groovy",
    [".*%.[jJ]enkinsfile"] = "groovy",
  },
})

vim.g.lazyvim_eslint_auto_format = true
vim.g.lazyvim_prettier_needs_config = false
vim.lsp.commands["setContext"] = function() end

vim.g.goalbe = nil

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = ".env*",
  callback = function()
    vim.bo.filetype = "sh"
  end,
})

if vim.g.neovide then
  vim.keymap.set({ "n", "v" }, "<C-S-v>", '"+P', { desc = "Paste from clipboard" })
  vim.keymap.set({ "i", "c" }, "<C-S-v>", "<C-R>+", { desc = "Paste from clipboard" })
  vim.keymap.set("t", "<C-S-v>", [[<C-\><C-n>"+Pi]], { desc = "Paste from clipboard" })

  vim.g.neovide_scale_factor = 1.0
  local function zoom(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function() zoom(1.1) end, { desc = "Zoom in" })
  vim.keymap.set("n", "<C-->", function() zoom(1 / 1.1) end, { desc = "Zoom out" })
  vim.keymap.set("n", "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Reset zoom" })

  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_padding_right = 0

  require("config.neovide_prefix").setup()

  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_scroll_animation_length = 0.2
end

vim.opt.guicursor = "n-v-c-sm:block-blinkwait700-blinkon600-blinkoff600,i-ci-ve:ver25-blinkwait700-blinkon600-blinkoff600,r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"

require("config.terminal_colors").setup()
require("config.terminal_panel").setup()
require("config.kitty_padding").setup()
vim.env.STARSHIP_CONFIG = vim.fn.expand("~/.config/starship-nvim.toml")
