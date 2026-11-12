-- IntelliJ-like Java view in the explorer:
--   * a module is a folder with @ApplicationModule, or (Modulith's default) a direct sub-package
--     of the @SpringBootApplication / @Modulithic package
--   * folders inside a module are internal (lock) unless marked @NamedInterface (open lock)
--   * .java files show their icon from config/java_icons.lua and no extension
local packages, app_roots = {}, {}

-- is <dir> the package of the @SpringBootApplication / @Modulithic class?
local function is_app_root(dir)
  if app_roots[dir] == nil then
    app_roots[dir] = false
    for _, file in ipairs(vim.fn.glob(dir .. "/*.java", false, true)) do
      local text = table.concat(vim.fn.readfile(file, "", 60), "\n")
      if text:find("@[%w_.]*SpringBootApplication") or text:find("@[%w_.]*Modulithic") then
        app_roots[dir] = true
        break
      end
    end
  end
  return app_roots[dir]
end

-- "module" / "named" / false, plus the displayName, from <dir>/package-info.java
local function package_info(dir)
  if packages[dir] == nil then
    packages[dir] = false
    local file = dir .. "/package-info.java"
    if vim.uv.fs_stat(file) then
      local text = table.concat(vim.fn.readfile(file, "", 30), "\n")
      if text:find("@[%w_.]*ApplicationModule") then
        packages[dir] = { kind = "module", name = text:match('displayName%s*=%s*"(.-)"') }
      elseif text:find("@[%w_.]*NamedInterface") then
        packages[dir] = { kind = "named" }
      end
    end
    if not packages[dir] and is_app_root(vim.fn.fnamemodify(dir, ":h")) then
      packages[dir] = { kind = "module" }
    end
  end
  return packages[dir]
end

local function inside_module(dir)
  local parent = vim.fn.fnamemodify(dir, ":h")
  while parent:find("/src/main/java/", 1, true) do
    local info = package_info(parent)
    if info and info.kind == "module" then
      return true
    end
    parent = vim.fn.fnamemodify(parent, ":h")
  end
  return false
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  callback = function()
    packages, app_roots = {}, {}
  end,
})

local function set_hl()
  local function hl(name, link) vim.api.nvim_set_hl(0, name, { link = link, default = true }) end
  hl("SnacksPickerSpringModule", "String")
  hl("SnacksPickerSpringNamed", "Function")
  -- most folders in a module are internal, so use a quiet color (Comment without the italic)
  local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  vim.api.nvim_set_hl(0, "SnacksPickerSpringInternal", { fg = comment.fg, ctermfg = comment.ctermfg, default = true })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

local function explorer_format(item, picker)
  local theme = require("config.icon_themes").get()
  local java = item.file and item.file:find("/src/%w+/java/") ~= nil
  local base = item.file and vim.fn.fnamemodify(item.file, ":t")
  local icon, name, name_hl

  if java and item.dir then
    local info = package_info(item.file)
    if info and info.kind == "module" then
      icon = { theme.ascii and "M" or "󰚝", "SnacksPickerSpringModule" }
      if info.name and info.name:lower() ~= base:lower() then
        item.comment = info.name
      end
    elseif info and info.kind == "named" then
      icon = { theme.ascii and "+" or "󰉑", "SnacksPickerSpringNamed" } -- md-folder_lock_open
    elseif not info and inside_module(item.file) then
      icon = { theme.ascii and "-" or "󰉐", "SnacksPickerSpringInternal" }
    end
  elseif item.file and not item.dir then
    icon = require("config.java_icons").icon(item.file)
    if icon and java and base:match("%.java$") and not base:match("%-info%.java$") then
      name = vim.fn.fnamemodify(base, ":r")
    end
  end

  if item.dir and (theme.rich or theme.ascii) then
    local glyph, hl, is_default = require("mini.icons").get("directory", base)
    -- snacks shows one icon for every open folder; keep the folder's own one
    if not icon and item.open and (theme.ascii or not is_default) then
      icon = { glyph, hl }
    end
    if hl == "IconThemeDim" then
      name_hl = hl
    end
  end

  name = name or item.compact
  local ret = Snacks.picker.format.file(item, picker)
  if icon or name or name_hl then
    -- the file icon is the segment right before the file name
    for i, seg in ipairs(ret) do
      if seg.field == "file" and i > 1 then
        if icon then
          ret[i - 1] = { Snacks.picker.util.align(icon[1], 2), icon[2], virtual = true }
        end
        if name then
          seg[1] = name
        end
        if name_hl then
          seg[2] = name_hl
        end
        break
      end
    end
  end
  return ret
end

-- Compact package chains in Java/Kotlin source trees, like IntelliJ's "Compact Middle Packages":
-- src/main/java/com/example/shop shows as one row "com.example.shop". A package folder whose only
-- entry is one sub-folder is skipped and its name prefixed to the child. Opening the row opens the
-- whole chain; closing it collapses the whole chain. Search results keep the plain tree.
local function single_subdir(path)
  local fs = vim.uv.fs_scandir(path)
  if not fs then
    return nil
  end
  local name, kind = vim.uv.fs_scandir_next(fs)
  if name and kind == "directory" and not vim.uv.fs_scandir_next(fs) then
    return name
  end
end

local function is_package_dir(path)
  return path:find("/src/[^/]+/java/.") or path:find("/src/[^/]+/kotlin/.")
end

local opened_by_chain = {} -- folders this code opened, so a later "closed" means the user closed it

local function explorer_finder(opts, ctx)
  local finder = require("snacks.picker.source.explorer").explorer(opts, ctx)
  if ctx.picker.matcher.opts.keep_parents then
    return finder -- searching
  end
  local Tree = require("snacks.explorer.tree")
  return function(cb)
    local skipped = {} ---@type table<table, { parent: table?, prefix: string, head: table }>
    finder(function(item)
      local via = item.parent and skipped[item.parent]
      if via then
        item.parent = via.parent
        item.compact = via.prefix .. "." .. vim.fn.fnamemodify(item.file, ":t")
        -- the merged row takes the place of the chain's first folder among its siblings
        local head = via.head
        item.last = nil
        setmetatable(item, { __index = function(_, key) return key == "last" and head.last or nil end })
      end

      local child = item.dir and is_package_dir(item.file) and single_subdir(item.file)
      if not child then
        return cb(item)
      end
      local prefix = item.compact or vim.fn.fnamemodify(item.file, ":t")

      if not item.open then
        -- collapsed: label the row with the whole chain
        local path, label = item.file .. "/" .. child, prefix .. "." .. child
        while true do
          local next_dir = single_subdir(path)
          if not next_dir then
            break
          end
          path, label = path .. "/" .. next_dir, label .. "." .. next_dir
        end
        item.compact = label
        return cb(item)
      end

      -- open: hide this folder and keep the chain open down to the real package
      local head = via and via.head or item
      local node = Tree:node(item.file .. "/" .. child)
      if node and not node.open then
        if opened_by_chain[node.path] then
          -- the user closed the merged row: collapse from the top of the chain
          opened_by_chain[node.path] = nil
          Tree:close(head.file)
        else
          node.open = true
          opened_by_chain[node.path] = true
        end
      end
      skipped[item] = { parent = item.parent, prefix = prefix, head = head }
    end)
  end
end

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
            diagnostics_open = true,
            format = explorer_format,
            finder = explorer_finder,
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
