return {
  {
    "stevearc/oil.nvim",
    opts = {
      columns = { "icon" },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    opts = {
      default_component_configs = {
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "",
        },
      },
      filesystem = {
        group_empty_dirs = false,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            actions = {
              copy_path = function(_, item)
                local path = Snacks.picker.util.path(item)
                local choices = {
                  { "Relative path", vim.fn.fnamemodify(path, ":.") },
                  { "Absolute path", path },
                  { "Name", vim.fn.fnamemodify(path, ":t") },
                  { "Folder", vim.fn.fnamemodify(path, ":h") },
                }
                vim.ui.select(choices, {
                  prompt = "Copy",
                  format_item = function(c) return c[1] .. ": " .. c[2] end,
                }, function(choice)
                  if choice then
                    vim.fn.setreg("+", choice[2])
                    Snacks.notify.info("Copied " .. choice[2])
                  end
                end)
              end,
              open_in_oil = function(_, item)
                local path = Snacks.picker.util.path(item)
                require("oil").open_float(vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h"))
              end,
              find_in_folder = function(_, item)
                local path = Snacks.picker.util.path(item)
                local dir = vim.fn.isdirectory(path) == 1 and path or vim.fn.fnamemodify(path, ":h")
                Snacks.picker.files({ cwd = dir, hidden = true })
              end,
            },
            win = {
              list = {
                keys = {
                  ["Y"] = "copy_path",
                  ["O"] = "open_in_oil",
                  ["F"] = "find_in_folder",
                },
              },
            },
          },
        },
      },
    },
  },
}
