return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
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
        win_options = { winblend = 0 },
      },
      keymaps = {
        ["q"] = "actions.close",
        ["<Esc>"] = "actions.close",
      },
    },
    config = function(_, opts)
      local oil = require("oil")
      oil.setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        callback = vim.schedule_wrap(function(args)
          local buf = args.data.buf
          if vim.api.nvim_get_current_buf() ~= buf then
            return
          end

          local function try_preview(attempts)
            if attempts <= 0 then
              return
            end
            local entry = oil.get_cursor_entry()
            if entry then
              oil.open_preview()
            else
              vim.defer_fn(function()
                try_preview(attempts - 1)
              end, 50)
            end
          end

          try_preview(10)
        end),
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
      {
        "<leader>-",
        function()
          require("oil").toggle_float(vim.fn.getcwd())
        end,
        desc = "Open Oil Root (Float)",
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    opts = {
      nerd_font = "auto",
      icons = {
        Array = "󰅪 ",
        Boolean = "󰨙 ",
        Class = "󰠱 ",
        Constant = "󰏿 ",
        Constructor = "󰒓 ",
        Enum = "󰕘 ",
        EnumMember = "󰕚 ",
        Event = "󱐋 ",
        Field = "󰜢 ",
        File = "󰈙 ",
        Function = "󰊕 ",
        Interface = "󰠱 ",
        Key = "󰌋 ",
        Method = "󰆧 ",
        Module = "󰏗 ",
        Namespace = "󰌗 ",
        Null = "󰟢 ",
        Number = "󰎠 ",
        Object = "󰅩 ",
        Operator = "󰆕 ",
        Package = "󰏖 ",
        Property = "󰖷 ",
        String = "󰀬 ",
        Struct = "󰙅 ",
        TypeParameter = "󰅲 ",
        Variable = "󰀫 ",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Code Outline" },
      { "{", "<cmd>AerialPrev<cr>", desc = "Prev Symbol" },
      { "}", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
    },
  },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_automatic = 1
    end,
  },
  {
    "3rd/image.nvim",
    build = false,
    ft = { "markdown", "norg", "typst" },
    opts = {
      processor = "magick_cli",
    },
  },
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   opts = {
  --     stiffness = 0.5,
  --     trailing_stiffness = 0.5,
  --     matrix_pixel_threshold = 0.5,
  --   },
  -- },
}
