local function twelve_hour(item)
  if not item.date then
    return
  end
  local date = item.date:gsub("^%a%a%a (%a%a%a %d+ %d+:%d%d)$", "%1")
  item.date = date:gsub("(%d+):(%d%d)", function(h, m)
    h = tonumber(h)
    return ("%d:%s%s"):format((h + 11) % 12 + 1, m, h < 12 and "AM" or "PM")
  end)
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        git_log = { transform = twelve_hour },
        git_log_file = { transform = twelve_hour },
        git_log_line = { transform = twelve_hour },
      },
    },
  },
}
