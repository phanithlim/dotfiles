-- Make terminal splits read as a separate panel: a darker background, a header
-- bar with the shell's folder, and left padding. Floating terminals are left alone.
local M = {}

local colors_file = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")

local function theme_background()
  if vim.fn.filereadable(colors_file) == 0 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(colors_file)) do
    local value = line:match('^%s*background%s*=%s*"#(%x+)"')
    if value then
      return tonumber(value, 16)
    end
  end
end

local function darken(color, amount)
  local r = math.floor(bit.rshift(color, 16) * (1 - amount))
  local g = math.floor(bit.band(bit.rshift(color, 8), 0xff) * (1 - amount))
  local b = math.floor(bit.band(color, 0xff) * (1 - amount))
  return bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
end

local function fg(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
end

local function set_highlights()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or theme_background()
  local panel_bg = bg and darken(bg, 0.25) or nil
  vim.api.nvim_set_hl(0, "TermPanel", { bg = panel_bg })
  vim.api.nvim_set_hl(0, "TermPanelHeader", { fg = fg("Title") or fg("Function"), bg = panel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelHeaderNC", { fg = fg("Comment"), bg = panel_bg })
end

-- The shell keeps b:term_title as "user@host:~/path", which follows `cd`.
function M.title()
  local title = vim.b.term_title or ""
  -- Before the shell sets a title, term_title is the buffer name ("term://…:/bin/bash").
  local path = not title:find("^term://") and title:match(":(.+)$") or vim.fn.getcwd()
  return " TERMINAL · " .. vim.fn.fnamemodify(vim.fn.expand(path), ":t")
end

local winhighlight = table.concat({
  "Normal:TermPanel",
  "NormalNC:TermPanel",
  "EndOfBuffer:TermPanel",
  "SignColumn:TermPanel",
  "WinBar:TermPanelHeader",
  "WinBarNC:TermPanelHeaderNC",
}, ",")

local function style(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "terminal" then
    return
  end
  vim.wo[win].winhighlight = winhighlight
  vim.wo[win].winbar = "%{%v:lua.require'config.terminal_panel'.title()%}"
  vim.wo[win].signcolumn = "yes:1"
end

function M.setup()
  local group = vim.api.nvim_create_augroup("terminal_panel", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  -- Scheduled so it runs after snacks.nvim applies its own window options.
  vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
          style(win)
        end
      end)
    end,
  })
  set_highlights()
end

return M
