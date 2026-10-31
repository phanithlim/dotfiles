local M = {}

local function count(lines, counts)
  for _, line in ipairs(lines) do
    local ws = line:match("^( +)[%w@]")
    if ws and (#ws == 2 or #ws == 4) then
      counts[#ws] = counts[#ws] + 1
    end
  end
end

function M.indent(buf)
  buf = buf or 0
  local counts = { [2] = 0, [4] = 0 }
  count(vim.api.nvim_buf_get_lines(buf, 0, 300, false), counts)
  if counts[2] + counts[4] == 0 then
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":h")
    for _, file in ipairs(vim.list_slice(vim.fn.glob(dir .. "/*.java", false, true), 1, 5)) do
      count(vim.fn.readfile(file, "", 100), counts)
    end
  end
  return counts[2] > 0 and counts[2] >= counts[4] / 4 and 2 or 4
end

return M
