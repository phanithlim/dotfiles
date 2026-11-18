-- themes Omarchy can switch to
local themes = {
	{
		"ribru17/bamboo.nvim",
		lazy = true,
		priority = 1000,
	},
	-- aether comes from Omarchy's theme.lua, so it is not listed here
	{
		"bjarneo/ethereal.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"bjarneo/hackerman.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
	},
	{
		"sainnhe/everforest",
		lazy = true,
		priority = 1000,
	},
	{
		"kepano/flexoki-neovim",
		lazy = true,
		priority = 1000,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"tahayvr/matteblack.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"loctvl842/monokai-pro.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"shaunsingh/nord.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
	},
}

-- reload the theme when Omarchy changes it
local theme_reload = {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local transparency_file = vim.fn.stdpath("config") .. "/after/transparency.lua"

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          package.loaded["plugins.theme"] = nil

          vim.schedule(function()
            local ok, theme_spec = pcall(require, "plugins.theme")
            if not ok then
              return
            end

            local theme_plugin_name = nil
            for _, spec in ipairs(theme_spec) do
              if spec[1] and spec[1] ~= "lazyvim/lazyvim" then
                theme_plugin_name = spec.name or spec[1]
                break
              end
            end

            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") then
              vim.cmd("syntax reset")
            end

            vim.o.background = "dark"

            if theme_plugin_name then
              local plugin = require("lazy.core.config").plugins[theme_plugin_name]
              if plugin then
                local plugin_dir = plugin.dir .. "/lua"
                require("lazy.core.util").walkmods(plugin_dir, function(modname)
                  package.loaded[modname] = nil
                  package.preload[modname] = nil
                end)
              end
            end

            for _, spec in ipairs(theme_spec) do
              if spec[1] == "lazyvim/lazyvim" and spec.opts and spec.opts.colorscheme then
                local colorscheme = spec.opts.colorscheme

                require("lazy.core.loader").colorscheme(colorscheme)

                vim.defer_fn(function()
                  pcall(vim.cmd.colorscheme, colorscheme)

                  vim.cmd("redraw!")

                  if vim.fn.filereadable(transparency_file) == 1 then
                    vim.defer_fn(function()
                      vim.cmd.source(transparency_file)

                      vim.api.nvim_exec_autocmds("colorscheme", { modeline = false })
                      vim.api.nvim_exec_autocmds("vimenter", { modeline = false })

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

-- status line
-- see-through middle, coloured mode and position
local status_line = {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		opts.options = opts.options or {}
		opts.options.theme = function()
			local theme = require("lualine.utils.loader").load_theme("auto")
			for _, mode in pairs(theme) do
				for _, section in ipairs({ "b", "c" }) do
					if mode[section] then
						mode[section].bg = "None"
					end
				end
			end
			return theme
		end

		-- no status line inside floating windows
		local nvim_opts = require("lualine.utils.nvim_opts")
		local set = nvim_opts.set
		nvim_opts.set = function(name, val, o)
			if o and o.window and vim.api.nvim_win_is_valid(o.window)
				and vim.api.nvim_win_get_config(o.window).relative ~= "" then
				return
			end
			return set(name, val, o)
		end

		-- Java version in JVM projects, red when it is not the .sdkmanrc one
		local jdk = require("java.jdk")
		table.insert(opts.sections.lualine_x, 1, {
			jdk.status,
			cond = jdk.show,
			color = function()
				return { fg = Snacks.util.color(jdk.mismatch() and "DiagnosticError" or "Special") }
			end,
		})

		local progress = require("ui.lsp_progress")
		progress.setup()
		table.insert(opts.sections.lualine_x, 1, {
			progress.status,
			cond = progress.active,
			color = function() return { fg = Snacks.util.color("Special") } end,
		})

		-- no file %, line:column or clock
		opts.sections.lualine_y = {}
		opts.sections.lualine_z = {}
		-- other windows: only the file name
		opts.inactive_sections = { lualine_c = { "filename" }, lualine_x = {} }
	end,
}

-- icons
local icons = {
  {
    "nvim-mini/mini.icons",
    opts = function(_, opts)
      return require("ui.icon_themes").extend(opts)
    end,
  },
}

-- start screen
local logo = [[
   ▄▄▄▄███▄▄▄▄    ▄█       ███    █▄     ▄████████
 ▄██▀▀▀███▀▀▀██▄ ███       ███    ███   ███    ███
 ███   ███   ███ ███       ███    ███   ███    █▀
 ███   ███   ███ ███       ███    ███  ▄███▄▄▄
 ███   ███   ███ ███       ███    ███ ▀▀███▀▀▀
 ███   ███   ███ ███       ███    ███   ███    █▄
 ███   ███   ███ ███▌    ▄ ███    ███   ███    ███
  ▀█   ███   █▀  █████▄▄██ ████████▀    ██████████
                 ▀]]

local logo_lines = vim.split(logo, "\n")
do
  local width = 0
  for _, l in ipairs(logo_lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end
  for i, l in ipairs(logo_lines) do logo_lines[i] = l .. string.rep(" ", width - vim.fn.strdisplaywidth(l)) end
end

local function fg(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
end

local function blend(a, b, t)
  local function ch(c, shift) return math.floor(c / 2 ^ shift) % 256 end
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    out = out + math.floor(ch(a, shift) + (ch(b, shift) - ch(a, shift)) * t + 0.5) * 2 ^ shift
  end
  return out
end

local function set_logo_hl()
  local from, to = fg("Title") or 0xd7af5f, fg("Special") or 0xfe8019
  for i = 1, #logo_lines do
    vim.api.nvim_set_hl(0, "MlueLogo" .. i, { fg = blend(from, to, (i - 1) / math.max(#logo_lines - 1, 1)) })
  end
end
set_logo_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_logo_hl })

local function logo_sections()
  local rows = {}
  for i, l in ipairs(logo_lines) do
    rows[i] = { text = { l, hl = "MlueLogo" .. i }, align = "center" }
  end
  rows[#rows].padding = 1
  return rows
end

local pick = function(source, opts)
  return function() Snacks.dashboard.pick(source, opts) end
end

local menu = {
  { { "f", "\u{f002}  ", "Find File", pick("files") }, { "g", "\u{f0b0}  ", "Find Text", pick("live_grep") } },
  { { "n", "\u{f15b}  ", "New File", ":ene | startinsert" }, { "c", "\u{f013}  ", "Config", pick("files", { cwd = vim.fn.stdpath("config") }) } },
  { { "r", "\u{f1da}  ", "Recent Files", pick("oldfiles") }, { "s", "\u{f0c7}  ", "Session", function() require("persistence").load() end } },
  { { "l", "\u{f04b2}  ", "Lazy", ":Lazy" }, { "q", "\u{f08b}  ", "Quit", ":qa" } },
}

local function cell(entry)
  return {
    { "[", hl = "Comment" }, { entry[1], hl = "key" }, { "]  ", hl = "Comment" },
    { entry[2], hl = "icon" }, { entry[3], hl = "Normal", width = 13 },
  }
end

local function menu_sections()
  local items = {}
  for i, row in ipairs(menu) do
    local left, right = row[1], row[2]
    local text = cell(left)
    table.insert(text, { string.rep(" ", 6) })
    vim.list_extend(text, cell(right))
    table.insert(items, { key = left[1], action = left[4], text = text, align = "center", padding = i == #menu and 2 or 1 })
    table.insert(items, { key = right[1], action = right[4], hidden = true })
  end
  return items
end

local quotes = {
  { "Simplicity is prerequisite for reliability.", "Edsger W. Dijkstra" },
  { "Programs must be written for people to read.", "Harold Abelson" },
  { "Make it work, make it right, make it fast.", "Kent Beck" },
  { "Premature optimization is the root of all evil.", "Donald Knuth" },
  { "Talk is cheap. Show me the code.", "Linus Torvalds" },
  { "First, solve the problem. Then, write the code.", "John Johnson" },
  { "Deleted code is debugged code.", "Jeff Sickel" },
  { "The best code is no code at all.", "Jeff Atwood" },
  { "Debugging is twice as hard as writing the code.", "Brian Kernighan" },
  { "Any fool can write code that a computer can understand.", "Martin Fowler" },
  { "Code never lies, comments sometimes do.", "Ron Jeffries" },
  { "If it hurts, do it more often.", "Martin Fowler" },
  { "Clarity is better than cleverness.", "Eric S. Raymond" },
  { "Done is better than perfect.", "Sheryl Sandberg" },
}
local quote = quotes[vim.uv.hrtime() % #quotes + 1]

local dashboard = {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        width = 60,
        sections = {
          logo_sections(),
          { text = { { "─── " .. os.date("%A, %b %d · %H:%M") .. " ───", hl = "footer" } }, align = "center", padding = 2 },
          menu_sections(),
          { text = { { "“" .. quote[1] .. "”", hl = "Comment" } }, align = "center" },
          { text = { { "— " .. quote[2], hl = "Comment" } }, align = "center" },
        },
      },
    },
  },
}

-- no LazyVim news popup
local no_news = {
  "LazyVim/LazyVim",
  opts = {
    news = {
      lazyvim = false,
      neovim = false,
    },
  },
}

-- smooth scrolling
-- j/k and arrows move one line, so they skip the scroll animation
local line_keys = {}
for _, key in ipairs({ "j", "k", "<Down>", "<Up>" }) do
  line_keys[vim.keycode(key)] = true
end
local by_line_key = false
vim.on_key(function(_, typed)
  if typed and typed ~= "" then
    by_line_key = line_keys[typed] or false
  end
end, vim.api.nvim_create_namespace("snacks_scroll_line_keys"))

local smooth_scroll = {
  "folke/snacks.nvim",
  opts = {
    -- thin indent lines
    indent = {
      indent = { char = "▏" },
      scope = { char = "▏" },
    },
    scroll = {
      enabled = not vim.g.neovide,
      animate = {
        duration = { step = 10, total = 250 },
        easing = "outQuad",
      },
      animate_repeat = {
        delay = 100,
        duration = { step = 10, total = 120 },
        easing = "outQuad",
      },
      filter = function(buf)
        return not by_line_key
          and vim.g.snacks_scroll ~= false
          and vim.b[buf].snacks_scroll ~= false
          and vim.bo[buf].buftype ~= "terminal"
      end,
    },
  },
}

-- popups and messages
local popups = {
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvimdev/dashboard-nvim", enabled = false },
  -- Alt+d / Alt+u scroll docs and previews
  {
    "folke/noice.nvim",
    keys = {
      { "<a-d>", function() require("noice.lsp").scroll(4) end, mode = { "i", "n", "s" }, desc = "Scroll docs down" },
      { "<a-u>", function() require("noice.lsp").scroll(-4) end, mode = { "i", "n", "s" }, desc = "Scroll docs up" },
    },
    opts = {
      lsp = {
        progress = { enabled = false },
      },
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
}

return {
  themes,
  theme_reload,
  status_line,
  icons,
  dashboard,
  no_news,
  smooth_scroll,
  popups,
}
