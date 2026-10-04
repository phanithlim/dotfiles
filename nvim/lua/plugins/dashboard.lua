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

do
  local lines, width = vim.split(logo, "\n"), 0
  for _, l in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end
  for i, l in ipairs(lines) do lines[i] = l .. string.rep(" ", width - vim.fn.strdisplaywidth(l)) end
  logo = table.concat(lines, "\n")
end

local pick = function(source, opts)
  return function() Snacks.dashboard.pick(source, opts) end
end

local menu = {
  { { "f", "Find File", pick("files") }, { "g", "Find Text", pick("live_grep") } },
  { { "n", "New File", ":ene | startinsert" }, { "c", "Config", pick("files", { cwd = vim.fn.stdpath("config") }) } },
  { { "r", "Recent Files", pick("oldfiles") }, { "s", "Session", function() require("persistence").load() end } },
  { { "l", "Lazy", ":Lazy" }, { "q", "Quit", ":qa" } },
}

local function cell(entry)
  return {
    { "[", hl = "special" }, { entry[1], hl = "key" }, { "]  ", hl = "special" },
    { entry[2], hl = "desc", width = 16 },
  }
end

local function menu_sections()
  local items = {}
  for i, row in ipairs(menu) do
    local left, right = row[1], row[2]
    local text = cell(left)
    table.insert(text, { string.rep(" ", 6) })
    vim.list_extend(text, cell(right))
    table.insert(items, { key = left[1], action = left[3], text = text, align = "center", padding = i == #menu and 2 or 1 })
    table.insert(items, { key = right[1], action = right[3], hidden = true })
  end
  return items
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        width = 60,
        sections = {
          { header = logo, padding = 1 },
          { text = { { "─── " .. os.date("%A, %b %d · %H:%M") .. " ───", hl = "footer" } }, align = "center", padding = 2 },
          menu_sections(),
          { section = "startup" },
        },
      },
    },
  },
}
