return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    preview = {
      update_on_cursor_moved = true,
    },
    view_options = {
      show_hidden = true,
      is_hardcoded_hidden_file = function(name)
        return name == ".."
      end,
    },
    float = {
      padding = 2,
      max_width = 0.8,
      min_width = 0.5,
      max_height = 0.8,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
    },
    keymaps = {
      ["q"] = "actions.close",
      ["<Esc>"] = "actions.close",
      ["p"] = "actions.preview",
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "OilEnter",
      callback = function()
        require("oil").open_preview()
      end,
    })
  end,
  keys = {
    {
      "_",
      function()
        require("oil").open()
      end,
      desc = "Open Oil",
    },
    {
      "-",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open Oil (Float)",
    },
  },
}
