return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>j",  "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",  desc = "Buffers" },
      { "<Tab>",      "<cmd>bnext<cr>",              desc = "Next Buffer" },
      { "<S-Tab>",    "<cmd>bprev<cr>",              desc = "Prev Buffer" },
    },
  },
}
