return {
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },

  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  -- Alt+D / Alt+U scroll the side panel (docs, previews) everywhere; <C-b> is the tmux prefix
  {
    "folke/noice.nvim",
    keys = {
      { "<a-d>", function() require("noice.lsp").scroll(4) end, mode = { "i", "n", "s" }, desc = "Scroll docs down" },
      { "<a-u>", function() require("noice.lsp").scroll(-4) end, mode = { "i", "n", "s" }, desc = "Scroll docs up" },
    },
    opts = {
      lsp = {
        progress = { enabled = false },
      },
      routes = {
        {
          filter = {
            event = "notify",
            find = "clipboard",
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<A-d>"] = { "scroll_documentation_down", "fallback" },
        ["<A-u>"] = { "scroll_documentation_up", "fallback" },
      },
    },
  },
  -- The automatic failure popup closes as soon as it opens, so use <leader>to instead.
  {
    "nvim-neotest/neotest",
    opts = { output = { open_on_run = false } },
  },
  { "nvimdev/dashboard-nvim", enabled = false },
  { "iamcco/markdown-preview.nvim", enabled = false },
}
