local orig_handler = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, params, ctx)
  if not params or not params.registrations then
    return vim.NIL
  end
  return orig_handler(err, params, ctx)
end

if vim.g.neovide then
  -- UI & Performance
  vim.o.guifont = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_scroll_animation_length = 0
  --
  -- -- The "Blur" Magic
  -- vim.g.neovide_floating_shadow = true
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 45
  -- vim.g.neovide_light_radius = 5
  --
  -- -- Transparency (Required for blur to show through)
  -- vim.o.winblend = 25
  -- vim.o.pumblend = 25
end
