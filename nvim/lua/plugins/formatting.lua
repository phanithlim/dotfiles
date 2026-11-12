return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
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
      java = { "google-java-format" },
    },
    formatters = {
      -- LazyVim's sql extra only runs sqlfluff when the project has a .sqlfluff
      -- (require_cwd). Run it everywhere, defaulting to the postgres dialect;
      -- a project .sqlfluff still controls the rules.
      sqlfluff = {
        args = { "format", "--dialect=postgres", "-" },
        require_cwd = false,
      },
      xmllint = {
        command = "xmllint",
        args = { "--format", "--indent-spaces", "2", "-" },
        stdin = true,
      },
    },
  },
}
