-- 12-hour times in the git log pickers (<leader>gl, gf, gb). Git's "human" date is 24-hour:
--   "Fri 16:33"        -> "Fri 4:33PM"      (this week)
--   "Mon Oct 26 22:59" -> "Oct 26 10:59PM"  (older; weekday dropped to fit the 16-char column)
-- Dates without a time ("Sep 30 2025", "2 hours ago") are left as they are.
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
