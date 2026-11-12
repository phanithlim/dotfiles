-- No `init` here: it would replace LazyVim's, which points nvim-web-devicons at mini.icons.
return {
  {
    "nvim-mini/mini.icons",
    opts = function(_, opts)
      return require("config.icon_themes").extend(opts)
    end,
  },
}
