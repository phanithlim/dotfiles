return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        local colorscheme = vim.g.colors_name or "gruvbox"
        vim.cmd("colorscheme " .. colorscheme)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        local colorscheme = vim.g.colors_name or "gruvbox"
        vim.cmd("colorscheme " .. colorscheme)
      end,
    },
  },
}
