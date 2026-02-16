return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
   ⚡ MLUE ⚡
   ──────────
    ]],
        -- stylua: ignore
        keys = {
          { icon = " ", key = "f", desc = "Find Stuff",         action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "Fresh Start",        action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Word Hunt",          action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Mistakes",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "The Brain",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Wake Up Session",    section = "session" },
          { icon = " ", key = "q", desc = "Escape Reality",     action = ":qa" },
        },
        },
      },
    },
  },
}
