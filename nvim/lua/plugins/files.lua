-- file tree (<leader>e)
-- IntelliJ-like Java view: Spring modules, internal folders, Java icons
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
  local theme = require("ui.icon_themes").get()
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
    icon = require("java.icons").icon(item.file)
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

-- show com/example/shop as one row "com.example.shop"
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

-- the only subfolder of <path>, if it can share a row with it: packages join packages,
-- other folders join other folders (so "java" never merges into "com.example...")
local function merge_child(path)
  local child = single_subdir(path)
  if child and not is_package_dir(path) == not is_package_dir(path .. "/" .. child) then
    return child
  end
end

-- "com.example" inside a package, "src/main" elsewhere
local function join(path, name)
  return (is_package_dir(path) and "." or "/") .. name
end

-- Gradle/Maven src/main and src/test: hidden, their folders show as "main/java", "test/resources"
local function is_source_set(path)
  if not path:find("/src/[^/]+$") then
    return false
  end
  for _, name in ipairs({ "java", "kotlin", "resources" }) do
    if vim.uv.fs_stat(path .. "/" .. name) then
      return true
    end
  end
  return false
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
        item.compact = via.prefix .. join(item.file, vim.fn.fnamemodify(item.file, ":t"))
        -- the merged row takes the place of the chain's first folder among its siblings
        local head = via.head
        item.last = nil
        setmetatable(item, { __index = function(_, key) return key == "last" and head.last or nil end })
      end

      -- an open folder keeps its source sets open: their rows are hidden, so they can't be opened by hand
      if item.dir and item.open then
        local node = Tree:node(item.file)
        for _, sub in pairs(node and node.children or {}) do
          if sub.dir and not sub.open and is_source_set(sub.path) then
            sub.open = true
          end
        end
      end
      if item.dir and item.open and item.parent and is_source_set(item.file) then
        local name = item.compact or vim.fn.fnamemodify(item.file, ":t")
        skipped[item] = { parent = item.parent, prefix = name, head = via and via.head or item }
        return
      end

      local child = item.dir and item.parent and merge_child(item.file)
      if not child then
        return cb(item)
      end
      local prefix = item.compact or vim.fn.fnamemodify(item.file, ":t")

      if not item.open then
        -- collapsed: label the row with the whole chain
        local path = item.file .. "/" .. child
        local label = prefix .. join(path, child)
        while true do
          local next_dir = merge_child(path)
          if not next_dir then
            break
          end
          path = path .. "/" .. next_dir
          label = label .. join(path, next_dir)
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

-- explorer colours: the editor's background and a soft selected row, only in the explorer's windows
local explorer_ns = vim.api.nvim_create_namespace("explorer_colors")

local function mix(a, b, amount)
  local ret = 0
  for shift = 16, 0, -8 do
    local x = bit.band(bit.rshift(a, shift), 255)
    local y = bit.band(bit.rshift(b, shift), 255)
    ret = ret + bit.lshift(math.floor(x + (y - x) * amount + 0.5), shift)
  end
  return ret
end

local function set_explorer_colors()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  if not (normal.bg and normal.fg) then
    return
  end
  for _, group in ipairs({ "NormalFloat", "SnacksNormal", "SnacksNormalNC", "SnacksPickerList", "SnacksPickerInput", "SnacksPickerBox" }) do
    vim.api.nvim_set_hl(explorer_ns, group, { fg = normal.fg, bg = normal.bg })
  end
  local selected = { bg = mix(normal.bg, normal.fg, 0.08) }
  vim.api.nvim_set_hl(explorer_ns, "CursorLine", selected)
  vim.api.nvim_set_hl(explorer_ns, "SnacksPickerListCursorLine", selected)
end
set_explorer_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_explorer_colors })

local function explorer_colors(picker)
  for _, win in ipairs({ picker.list.win.win, picker.input.win.win, picker.layout.root.win }) do
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_hl_ns(win, explorer_ns)
    end
  end
end

local file_tree = {
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
            -- fewer lines: indent the tree without guide lines
            icons = { tree = { vertical = "  ", middle = "  ", last = "  " } },
            on_show = explorer_colors,
            layout = {
              layout = {
                backdrop = false,
                width = 40,
                min_width = 40,
                height = 0,
                position = "left",
                border = "none",
                box = "vertical",
                { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", height = 0.4, border = "top" },
              },
            },
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

-- find files and text
-- file name first, Java shows class and package, Alt+T hides tests
local function java_format(item, picker)
  return require("java.icons").format(item, picker)
end

local function hide_tests(item, ctx)
  if ctx.picker.opts.no_tests and ("/" .. item.file):find("/src/test/", 1, true) then
    return false
  end
end

local function file_source()
  return {
    format = java_format,
    transform = hide_tests,
    toggles = { no_tests = "T" },
    win = { input = { keys = { ["<a-T>"] = { "toggle_no_tests", mode = { "n", "i" } } } } },
  }
end

-- Go to Class, like IntelliJ: matches the class name only, so CDKC finds CamDigiKeyClient
local function classes()
  Snacks.picker.files(vim.tbl_extend("force", file_source(), {
    title = "Classes",
    cwd = LazyVim.root(),
    ft = "java",
    transform = function(item, ctx)
      if hide_tests(item, ctx) == false or item.file:match("%-info%.java$") then
        return false
      end
      item.text = vim.fn.fnamemodify(item.file, ":t:r")
    end,
  }))
end

local finder = {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fj", classes, desc = "Find Java Class" },
    },
    opts = {
      picker = {
        matcher = { frecency = true },
        formatters = { file = { filename_first = true } },
        -- preview scroll on Alt+D / Alt+U, like oil and the docs popups
        win = {
          input = { keys = {
            ["<a-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
          } },
          list = { keys = { ["<a-d>"] = "preview_scroll_down", ["<a-u>"] = "preview_scroll_up" } },
        },
        sources = {
          files = file_source(),
          git_files = file_source(),
          recent = { format = java_format },
          smart = { format = java_format },
          grep = { format = java_format },
        },
      },
    },
  },
}

-- oil: edit folders like text (-)
local oil = {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      -- deleted files can be restored from the trash
      delete_to_trash = true,
      -- moving a .java file asks jdtls to fix the package line and imports, then saves them
      lsp_file_methods = {
        timeout_ms = 10000,
        autosave_changes = true,
      },
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
      -- no status line in the preview
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
        -- Java folders: "app · com.example.shop" (test code adds "· test"); others: path from the project
        get_win_title = function(win)
          local dir = (require("oil").get_current_dir(vim.api.nvim_win_get_buf(win)) or ""):gsub("/$", "")
          local module, set, package = dir:match("^(.-)/src/([%w-]+)/java/?(.*)$")
          if module then
            local parts = { vim.fn.fnamemodify(module, ":t") }
            if set ~= "main" then
              table.insert(parts, set)
            end
            table.insert(parts, package ~= "" and package:gsub("/", ".") or "(default package)")
            return " " .. table.concat(parts, " · ") .. " "
          end
          return " " .. vim.fn.fnamemodify(dir, ":~:.") .. " "
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
      require("java.icons").patch_oil()

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
          -- under every float: Neovim draws a float under a blended float as blank, which emptied the explorer
          zindex = 1,
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
}

-- harpoon: pinned files
local function list()
  return require("harpoon"):list()
end

local function pick()
  local items = {}
  for i = 1, list():length() do
    local item = list():get(i)
    if item and item.value ~= "" then
      table.insert(items, { idx = i, text = item.value, file = vim.fn.fnamemodify(item.value, ":p") })
    end
  end
  Snacks.picker({ title = "Harpoon", items = items, format = "file", preview = "file" })
end

local keys = {
  { "<leader>h", "", desc = "+harpoon" },
  { "<leader>a", function() list():add() end, desc = "Harpoon Add" },
  { "<leader>hc", function() list():clear() require("ui.harpoon_bar").update() end, desc = "Harpoon Clear All" },
  { "<leader>hh", pick, desc = "Harpoon Picker" },
  { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(list()) end, desc = "Harpoon Menu" },
  { "<C-p>", function() list():prev() end, desc = "Harpoon Prev" },
  { "<C-n>", function() list():next() end, desc = "Harpoon Next" },
}
for i = 1, 4 do
  table.insert(keys, { "<leader>" .. i, function() list():select(i) end, desc = "Harpoon " .. i })
  table.insert(keys, { "<M-" .. i .. ">", function() list():select(i) end, desc = "Harpoon " .. i })
  table.insert(keys, { "<leader>h" .. i, function() list():replace_at(i) end, desc = "Harpoon Set Slot " .. i })
end

local harpoon = {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 4,
        },
        settings = {
          save_on_toggle = true,
          key = function()
            local root = vim.fs.root(0, ".git")
            return root or vim.loop.cwd()
          end,
        },
      })

      local bar = require("ui.harpoon_bar")
      local function refresh()
        vim.schedule(bar.update)
      end
      harpoon:extend({ ADD = refresh, REMOVE = refresh, REPLACE = refresh, REORDER = refresh, LIST_CHANGE = refresh })
      bar.setup()
    end,
    keys = keys,
  },
}

-- buffer keys
local buffers = {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fb", "<cmd>Telescope buffers<cr>",  desc = "Buffers" },
      { "<Tab>",      "<cmd>bnext<cr>",              desc = "Next Buffer" },
      { "<S-Tab>",    "<cmd>bprev<cr>",              desc = "Prev Buffer" },
    },
  },
}

return {
  file_tree,
  finder,
  oil,
  harpoon,
  buffers,
}
