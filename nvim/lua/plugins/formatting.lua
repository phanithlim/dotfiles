return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      -- VSCode-style formatting for web files (Prettier, installed via Mason).
      -- Falls back to the LSP formatter only if prettier is unavailable.
      vue = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      graphql = { "prettier" },
      xml = { "xmllint" },
    },
    formatters = {
      xmllint = {
        command = "xmllint",
        args = { "--format", "--indent-spaces", "2", "-" },
        stdin = true,
      },
    },
  },
}
