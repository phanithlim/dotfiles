-- File name badge at the top-right of each file window:  PayoutService.java ● 1 ⚠ 2
-- It lives in the winbar, not a floating window: a float over the text makes
-- every scroll repaint the whole window, which stutters inside herdr/kitty.
local M = {}

local colors_file = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")
local palette
local defined = {} -- highlight groups made for the badge

local function load_palette()
  local c = {}
  if vim.fn.filereadable(colors_file) == 1 then
    for _, line in ipairs(vim.fn.readfile(colors_file)) do
      local key, value = line:match('^%s*([%w_]+)%s*=%s*"(#%x+)"')
      if key then
        c[key] = value
      end
    end
  end
  palette = {
    crust = c.darker_background or "#11111b",
    surface = c.lighter_background or "#313244",
    text = c.foreground or "#cdd6f4",
    dim = c.dark_foreground or "#6c7086",
    accent = c.accent or "#89b4fa",
    red = c.red or "#f38ba8",
    yellow = c.yellow or "#f9e2af",
  }
end

-- "%#Group#" for these colours, making the group the first time
local function hl(fg, bg, bold)
  local name = ("FileBadge_%s_%s_%s"):format(fg or "none", bg or "none", bold and "b" or "n"):gsub("#", "")
  if not defined[name] then
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = bold })
    defined[name] = true
  end
  return "%#" .. name .. "#"
end

local LEFT, RIGHT = "\u{e0b6}", "\u{e0b4}"

function M.render()
  local win = vim.g.statusline_winid
  if type(win) ~= "number" or not vim.api.nvim_win_is_valid(win) then
    win = vim.api.nvim_get_current_win()
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local focused = win == vim.api.nvim_get_current_win()
  local p = palette

  local path = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(path, ":t")
  if name == "" then
    name = "[No Name]"
  end
  local icon
  -- Java files: the same role / type icon as the explorer (config/java_icons.lua)
  local java = path ~= "" and require("config.java_icons").icon(path)
  if java then
    icon = java[1]
  else
    icon = require("nvim-web-devicons").get_icon(name)
  end
  -- The icon pill takes the theme's accent, not the file type's own colour.
  local icon_bg = focused and p.accent or p.dim
  local text_fg = focused and p.text or p.dim

  local parts = {
    "%=",
    hl(icon_bg, nil), LEFT,
    hl(p.crust, icon_bg), (icon or "\u{f15b}") .. " ",
    hl(text_fg, p.surface, focused), " " .. name:gsub("%%", "%%%%"),
  }
  if vim.bo[buf].modified then
    vim.list_extend(parts, { hl(p.yellow, p.surface), " \u{25cf}" })
  end
  local errors = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN })
  if errors > 0 then
    vim.list_extend(parts, { hl(p.red, p.surface), " \u{f057} " .. errors })
  end
  if warnings > 0 then
    vim.list_extend(parts, { hl(p.yellow, p.surface), " \u{f071} " .. warnings })
  end
  vim.list_extend(parts, { hl(text_fg, p.surface), " ", hl(p.surface, nil), RIGHT, "%#WinBar# " })
  return table.concat(parts)
end

local WINBAR = "%{%v:lua.require'config.file_badge'.render()%}"

-- file windows get the badge; a window that now shows something else loses it
-- (the terminal panel sets its own winbar)
local function attach(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  local buftype = vim.bo[vim.api.nvim_win_get_buf(win)].buftype
  if buftype == "" then
    vim.wo[win].winbar = WINBAR
  elseif buftype ~= "terminal" and vim.wo[win].winbar == WINBAR then
    vim.wo[win].winbar = ""
  end
end

local function set_highlights()
  defined = {}
  load_palette()
  -- the bar row blends into the editor background
  vim.api.nvim_set_hl(0, "WinBar", { link = "Normal" })
  vim.api.nvim_set_hl(0, "WinBarNC", { link = "Normal" })
end

function M.setup()
  set_highlights()
  local group = vim.api.nvim_create_augroup("file_badge", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "FileType" }, {
    group = group,
    callback = function()
      attach(vim.api.nvim_get_current_win())
    end,
  })
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus!")
    end),
  })
end

return M
