return {
  "nvim-lua/plenary.nvim", -- already in lazyvim
  lazy = false,
  keys = {
    { "<leader>mm", "<cmd>lua require('maven-panel').toggle()<cr>", desc = "Maven Panel" },
  },
}
