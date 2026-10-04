if not vim.g.neovide then
  return {}
end

return {
  {
    "folke/noice.nvim",
    keys = {
      { "<c-b>", false, mode = "n" },
    },
  },
}
