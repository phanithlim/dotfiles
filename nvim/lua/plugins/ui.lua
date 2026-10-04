return {
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },

  -- Buffer StatusBar
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  -- {
  --   "b0o/incline.nvim",
  --   dependencies = {},
  --   enabled = false,
  --   event = "BufReadPre",
  --   priority = 1200,
  --   config = function()
  --     local helpers = require("incline.helpers")
  --     require("incline").setup({
  --       window = {
  --         padding = 0,
  --         margin = { horizontal = 0 },
  --       },
  --       render = function(props)
  --         local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  --         local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
  --         local modified = vim.bo[props.buf].modified
  --
  --         -- Diagnostics
  --         local function get_diagnostic_label()
  --           local icons = { error = "", warn = "", info = "", hint = "" }
  --           local label = {}
  --           for severity, icon in pairs(icons) do
  --             local n = #vim.diagnostic.get(props.buf, {
  --               severity = vim.diagnostic.severity[string.upper(severity)],
  --             })
  --             if n > 0 then
  --               table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
  --             end
  --           end
  --           return label
  --         end
  --
  --         local buffer = {
  --           { get_diagnostic_label() },
  --           ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
  --           " ",
  --           { filename, gui = modified and "bold,italic" or "bold" },
  --           " ",
  --           guibg = "#363944",
  --         }
  --         return buffer
  --       end,
  --     })
  --   end,
  -- },
  {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local helpers = require("incline.helpers")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local path = vim.api.nvim_buf_get_name(props.buf)
          local filename = vim.fn.fnamemodify(path, ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local modified = vim.bo[props.buf].modified

          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local icon_block = ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or ""

          return {
            icon_block,
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#363944",
          }
        end,
      })
    end,
  },
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            find = "clipboard",
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    lazy = false,
    opts = function()
      local logo = [[
   ▄▄▄▄███▄▄▄▄    ▄█       ███    █▄     ▄████████ 
 ▄██▀▀▀███▀▀▀██▄ ███       ███    ███   ███    ███ 
 ███   ███   ███ ███       ███    ███   ███    █▀  
 ███   ███   ███ ███       ███    ███  ▄███▄▄▄     
 ███   ███   ███ ███       ███    ███ ▀▀███▀▀▀     
 ███   ███   ███ ███       ███    ███   ███    █▄  
 ███   ███   ███ ███▌    ▄ ███    ███   ███    ███ 
  ▀█   ███   █▀  █████▄▄██ ████████▀    ██████████ 
                 ▀                                 
    ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            {
              action = "lua LazyVim.pick()()",
              desc = " Find File",
              icon = " ",
              key = "f",
            },
            {
              action = "ene | startinsert",
              desc = " New File",
              icon = " ",
              key = "n",
            },
            {
              action = 'lua LazyVim.pick("oldfiles")()',
              desc = " Recent Files",
              icon = " ",
              key = "r",
            },
            {
              action = 'lua LazyVim.pick("live_grep")()',
              desc = " Find Text",
              icon = " ",
              key = "g",
            },
            {
              action = "lua LazyVim.pick.config_files()()",
              desc = " Config",
              icon = " ",
              key = "c",
            },
            {
              action = 'lua require("persistence").load()',
              desc = " Restore Session",
              icon = " ",
              key = "s",
            },
            {
              action = "LazyExtras",
              desc = " Lazy Extras",
              icon = " ",
              key = "x",
            },
            {
              action = "Lazy",
              desc = " Lazy",
              icon = "󰒲 ",
              key = "l",
            },
            {
              action = function()
                vim.api.nvim_input("<cmd>qa<cr>")
              end,
              desc = " Quit",
              icon = " ",
              key = "q",
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- open dashboard after closing lazy
      if vim.o.filetype == "lazy" then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      return opts
    end,
  },
  -- Markdown preview (from the lang.markdown extra)
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
