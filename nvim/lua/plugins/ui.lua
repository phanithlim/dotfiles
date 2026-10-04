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
  { "nvimdev/dashboard-nvim", enabled = false },
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
