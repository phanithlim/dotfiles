return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp", "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", function() require("config.herdr_nav").go("h") end, desc = "Navigate Left" },
      { "<C-j>", function() require("config.herdr_nav").go("j") end, desc = "Navigate Down" },
      { "<C-k>", function() require("config.herdr_nav").go("k") end, desc = "Navigate Up" },
      { "<C-l>", function() require("config.herdr_nav").go("l") end, desc = "Navigate Right" },
    },
  },
}
