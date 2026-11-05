return {
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
      anti_conceal = { enabled = false },
      win_options = {
        concealcursor = { rendered = "nc" },
      },
    },
  },
}
