return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = not vim.g.neovide,
      -- slow enough for the eye to follow
      animate = {
        duration = { step = 10, total = 250 },
        easing = "outQuad",
      },
      -- holding or repeating a scroll key (default 50ms felt like a jump)
      animate_repeat = {
        delay = 100,
        duration = { step = 10, total = 120 },
        easing = "outQuad",
      },
    },
  },
}
