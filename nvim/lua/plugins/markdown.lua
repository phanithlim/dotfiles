return {
  -- Notes don't need style rules like line length.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = { enabled = true },
      -- Keep the cursor line rendered too, so lines don't shift as you move.
      anti_conceal = { enabled = false },
      win_options = {
        concealcursor = { rendered = "nc" },
      },
    },
  },
}
