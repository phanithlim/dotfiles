-- Ctrl+D / Ctrl+U: half a page, cursor stays on the same screen row.
-- Counts screen rows, so code lens lines don't push the cursor.
local M = {}

-- code lens rows above line `lnum`
local function fill_above(win, lnum)
  local ok, h = pcall(vim.api.nvim_win_text_height, win, { start_row = lnum - 1, end_row = lnum - 1 })
  return ok and h.fill or 0
end

-- the view one row up, or nil at the top of the buffer
local function one_row_up(win, view)
  if view.topfill < fill_above(win, view.topline) then
    return { topline = view.topline, topfill = view.topfill + 1 }
  elseif view.topline > 1 then
    return { topline = view.topline - 1, topfill = 0 }
  end
end

function M.half_page(down)
  local win = vim.api.nvim_get_current_win()
  local row = vim.fn.winline()
  local half = math.floor(vim.api.nvim_win_get_height(win) / 2)
  vim.cmd("normal! " .. half .. (down and "gj" or "gk"))
  local line = vim.fn.line(".")
  vim.fn.winrestview({ topline = line, topfill = fill_above(win, line) })
  while vim.fn.winline() < row do
    local view = one_row_up(win, vim.fn.winsaveview())
    if not view then
      break
    end
    vim.fn.winrestview(view)
  end
end

function M.setup()
  vim.keymap.set({ "n", "x" }, "<C-d>", function() M.half_page(true) end, { desc = "Half page down" })
  vim.keymap.set({ "n", "x" }, "<C-u>", function() M.half_page(false) end, { desc = "Half page up" })
end

return M
