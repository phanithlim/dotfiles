-- Snacks flags any file whose *average* line length exceeds 1000 chars as a
-- "bigfile" (filetype = bigfile), which disables LSP/treesitter/formatters.
-- A minified 50 KB JSON on one line trips this. Only treat files as big when
-- they are actually large; keep the minified-file heuristic for huge lines.
return {
  "folke/snacks.nvim",
  opts = {
    bigfile = {
      size = 1.5 * 1024 * 1024, -- 1.5MB
      line_length = 100000, -- only truly enormous single lines count as "big"
    },
  },
}
