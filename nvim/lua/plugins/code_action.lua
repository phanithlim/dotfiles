-- <leader>ca: code actions with a before/after preview of each change
return {
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "LspAttach",
    opts = {
      backend = "vim",
      picker = "snacks",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            {
              "<leader>ca",
              function()
                -- in a .vue file's <template>, TypeScript refactors can't work: show only fixes there
                local in_template = vim.bo.filetype == "vue"
                  and vim.fn.search("^<script", "bnW") <= vim.fn.search("^</script>", "bnW")
                require("tiny-code-action").code_action(in_template and {
                  filter = function(action) return not (action.kind or ""):match("^refactor") end,
                } or {})
              end,
              mode = { "n", "x" },
              desc = "Code Action (preview)",
              has = "codeAction",
            },
          },
        },
      },
    },
  },
}
