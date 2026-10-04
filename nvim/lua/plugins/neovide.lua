-- In Neovide, normal-mode <C-b> is the tmux-style prefix (config/neovide_prefix.lua),
-- which also scrolls noice hover popups, so drop noice's own normal-mode <C-b>.
if not vim.g.neovide then
  return {}
end

return {
  {
    "folke/noice.nvim",
    keys = {
      { "<c-b>", false, mode = "n" },
    },
  },
}
