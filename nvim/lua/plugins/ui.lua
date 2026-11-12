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

  {
    "folke/noice.nvim",
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
  -- The automatic failure popup closes as soon as it opens, so use <leader>to instead.
  {
    "nvim-neotest/neotest",
    opts = { output = { open_on_run = false } },
  },
  { "nvimdev/dashboard-nvim", enabled = false },
  { "iamcco/markdown-preview.nvim", enabled = false },
}
