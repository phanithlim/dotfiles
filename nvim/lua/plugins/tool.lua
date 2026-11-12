return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      view_options = {
        show_hidden = true,
        -- no "../" row: `-` goes up, and the preview starts on a real entry
        is_always_hidden = function(name)
          return name == ".."
        end,
      },
      win_options = {
        number = false,
        relativenumber = false,
      },
      -- Nvim 0.12 floats can show a statusline; the preview copies lualine's from the editor
      -- window, which adds a "[No Name] 1:1" row and makes it taller than the list
      preview_win = { win_options = { statusline = "" } },
      float = {
        padding = 2,
        max_width = 0.8,
        min_width = 0.5,
        max_height = 0.8,
        border = "rounded",
        win_options = { winblend = 0 },
        -- key hints in the bottom border: shown once, and the list keeps its full height
        override = function(conf)
          conf.footer = " ⏎ open · - up · A-d/A-u scroll · g. hidden · q close "
          conf.footer_pos = "center"
          return conf
        end,
        get_win_title = function(win)
          local dir = require("oil").get_current_dir(vim.api.nvim_win_get_buf(win)) or ""
          return " " .. vim.fn.pathshorten(vim.fn.fnamemodify(dir, ":~")) .. " "
        end,
      },
      keymaps = {
        ["q"] = "actions.close",
        ["<Esc>"] = "actions.close",
        ["<A-d>"] = "actions.preview_scroll_down",
        ["<A-u>"] = "actions.preview_scroll_up",
      },
    },
    config = function(_, opts)
      local oil = require("oil")
      oil.setup(opts)
      require("config.java_icons").patch_oil()

      -- dim the editor behind the oil float, like snacks pickers
      local function backdrop(win)
        local config = vim.api.nvim_win_get_config(win)
        if config.relative == "" or vim.w[win].oil_backdrop or Snacks.util.is_transparent() then
          return
        end
        vim.w[win].oil_backdrop = true
        vim.api.nvim_set_hl(0, "OilBackdrop", { bg = "#000000" })
        local dim = Snacks.win({
          enter = false,
          backdrop = false,
          focusable = false,
          style = "minimal",
          border = "none",
          relative = "editor",
          width = 0,
          height = 0,
          zindex = (config.zindex or 50) - 1,
          wo = { winhighlight = "Normal:OilBackdrop", winblend = 60 },
          bo = { filetype = "snacks_win_backdrop" },
        })
        -- clicking outside closes the oil float; take its preview and the backdrop with it
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(win),
          once = true,
          callback = function()
            dim:close()
            local preview = require("oil.util").get_preview_win()
            if preview then
              pcall(vim.api.nvim_win_close, preview, true)
            end
          end,
        })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        callback = vim.schedule_wrap(function(args)
          local buf = args.data.buf
          if vim.api.nvim_get_current_buf() ~= buf then
            return
          end
          backdrop(vim.api.nvim_get_current_win())

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
    ft = { "norg", "typst" },
    opts = {
      processor = "magick_cli",
    },
  },
}
