-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Workaround for Neovim 0.11.x bug where client/registerCapability handler
-- crashes with `ipairs(nil)` when an LSP server (e.g. jdtls) sends a
-- registerCapability request with nil registrations.
-- See: https://github.com/neovim/neovim/issues/31953
local orig_handler = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, params, ctx)
  if not params or not params.registrations then
    return vim.NIL
  end
  return orig_handler(err, params, ctx)
end
