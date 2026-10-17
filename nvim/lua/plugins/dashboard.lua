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

return {
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
          { pane = 2, icon = "\u{f017} ", title = "Recent Files", section = "recent_files", cwd = true, limit = 6, indent = 2, padding = 1 },
          { pane = 2, icon = "\u{f07b} ", title = "Projects", section = "projects", limit = 5, indent = 2, padding = 1 },
          function()
            return {
              pane = 2,
              icon = "\u{e702} ",
              title = "Git Status",
              section = "terminal",
              enabled = Snacks.git.get_root() ~= nil,
              cmd = "git status --short --branch --renames",
              height = 6,
              indent = 3,
              padding = 1,
              ttl = 5 * 60,
            }
          end,
        },
      },
    },
  },
}
