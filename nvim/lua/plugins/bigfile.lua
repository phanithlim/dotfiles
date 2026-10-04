return {
  "folke/snacks.nvim",
  opts = {
    bigfile = {
      size = 1.5 * 1024 * 1024, -- 1.5MB
      line_length = 100000, -- only truly enormous single lines count as "big"
    },
  },
}
