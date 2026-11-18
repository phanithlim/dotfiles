-- terminal and lazygit
local terminal = {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = { position = "bottom", height = 0.3 },
    },
    lazygit = {
      win = { position = "float", width = 0.9, height = 0.9 },
    },
  },
}

-- move between windows with Ctrl+h/j/k/l
local window_moves = {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp", "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right" },
    },
  },
}

return {
  terminal,
  window_moves,
}
