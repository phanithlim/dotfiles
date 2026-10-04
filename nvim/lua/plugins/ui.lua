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
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local helpers = require("incline.helpers")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local path = vim.api.nvim_buf_get_name(props.buf)
          local filename = vim.fn.fnamemodify(path, ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local modified = vim.bo[props.buf].modified

          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local icon_block = ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or ""

          return {
            icon_block,
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#363944",
          }
        end,
      })
    end,
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
