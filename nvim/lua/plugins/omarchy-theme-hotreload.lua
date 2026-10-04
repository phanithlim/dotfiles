return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local transparency_file = vim.fn.stdpath("config") .. "/after/transparency.lua"
      if vim.fn.filereadable(transparency_file) == 0 then
        transparency_file = vim.fn.stdpath("config") .. "/transparency.lua"
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          -- Unload the theme module
          package.loaded["plugins.theme"] = nil

          vim.schedule(function()
            local ok, theme_spec = pcall(require, "plugins.theme")
            if not ok then
              return
            end

            -- find the theme plugin and unload it
            local theme_plugin_name = nil
            for _, spec in ipairs(theme_spec) do
              if spec[1] and spec[1] ~= "lazyvim/lazyvim" then
                theme_plugin_name = spec.name or spec[1]
                break
              end
            end

            -- clear all highlight groups before applying new theme
            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") then
              vim.cmd("syntax reset")
            end

            -- reset background to default so colorscheme can set it properly (light themes will set to light)
            vim.o.background = "dark"

            -- unload theme plugin modules to force full reload
            if theme_plugin_name then
              local plugin = require("lazy.core.config").plugins[theme_plugin_name]
              if plugin then
                -- unload all lua modules from the plugin directory
                local plugin_dir = plugin.dir .. "/lua"
                require("lazy.core.util").walkmods(plugin_dir, function(modname)
                  package.loaded[modname] = nil
                  package.preload[modname] = nil
                end)
              end
            end

            -- find and apply the new colorscheme
            for _, spec in ipairs(theme_spec) do
              if spec[1] == "lazyvim/lazyvim" and spec.opts and spec.opts.colorscheme then
                local colorscheme = spec.opts.colorscheme

                -- load the colorscheme plugin
                require("lazy.core.loader").colorscheme(colorscheme)

                vim.defer_fn(function()
                  -- apply the colorscheme (it will set background itself)
                  pcall(vim.cmd.colorscheme, colorscheme)

                  -- force redraw to update all ui elements
                  vim.cmd("redraw!")

                  -- reload transparency settings
                  if vim.fn.filereadable(transparency_file) == 1 then
                    vim.defer_fn(function()
                      vim.cmd.source(transparency_file)

                      -- trigger ui updates for various plugins
                      vim.api.nvim_exec_autocmds("colorscheme", { modeline = false })
                      vim.api.nvim_exec_autocmds("vimenter", { modeline = false })

                      -- final redraw
                      vim.cmd("redraw!")
                    end, 5)
                  end
                end, 5)

                break
              end
            end
          end)
        end,
      })
    end,
  },
}
