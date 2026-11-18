-- keep 10 lines around the cursor, one row at a time
local M = {}

local MARGIN = 10

-- filler rows (code lens and other virtual lines) above line `lnum`
local function fill_above(win, lnum)
  local ok, h = pcall(vim.api.nvim_win_text_height, win, { start_row = lnum - 1, end_row = lnum - 1 })
  return ok and h.fill or 0
end

-- the view one row up (show more above) or down, or nil at the end of the buffer
local function one_row(win, view, up)
  if up then
    if view.topfill < fill_above(win, view.topline) then
      return { topline = view.topline, topfill = view.topfill + 1 }
    elseif view.topline > 1 then
      return { topline = view.topline - 1, topfill = 0 }
    end
  else
    if view.topfill > 0 then
      return { topline = view.topline, topfill = view.topfill - 1 }
    elseif vim.fn.line("w$") < vim.fn.line("$") then
      return { topline = view.topline + 1, topfill = 0 }
    end
  end
end

local function keep_margin()
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  local buftype = vim.bo.buftype
  if buftype == "terminal" or buftype == "prompt" then
    return
  end
  local height = vim.api.nvim_win_get_height(win) - (vim.wo[win].winbar ~= "" and 1 or 0)
  local margin = math.min(MARGIN, math.floor((height - 1) / 2))
  for _ = 1, height do
    local row = vim.fn.winline()
    local up = row <= margin
    if not up and row <= height - margin then
      return
    end
    local view = one_row(win, vim.fn.winsaveview(), up)
    if not view then
      return
    end
    vim.fn.winrestview(view)
  end
end

-- Ctrl+D / Ctrl+U: half a page, cursor stays on the same screen row
function M.half_page(down)
  local win = vim.api.nvim_get_current_win()
  local row = vim.fn.winline()
  local half = math.floor(vim.api.nvim_win_get_height(win) / 2)
  vim.cmd("normal! " .. half .. (down and "gj" or "gk"))
  local line = vim.fn.line(".")
  vim.fn.winrestview({ topline = line, topfill = fill_above(win, line) })
  while vim.fn.winline() < row do
    local view = one_row(win, vim.fn.winsaveview(), true)
    if not view then
      break
    end
    vim.fn.winrestview(view)
  end
end

function M.setup()
  vim.keymap.set({ "n", "x" }, "<C-d>", function() M.half_page(true) end, { desc = "Half page down" })
  vim.keymap.set({ "n", "x" }, "<C-u>", function() M.half_page(false) end, { desc = "Half page up" })
  -- Neovim's scrolloff stays off in normal/visual mode; insert mode keeps the built-in one
  vim.opt.scrolloff = 0
  local group = vim.api.nvim_create_augroup("scroll_margin", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", { group = group, callback = keep_margin })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function() vim.wo.scrolloff = MARGIN end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function() vim.wo.scrolloff = 0 end,
  })
end

return M
