-- Ctrl+h/j/k/l: move between Neovim splits, then on into the next herdr pane.
-- Herdr can't pass these keys only to Neovim, so going back is Ctrl+B then h/j/k/l.
-- Outside herdr (tmux, Neovide) vim-tmux-navigator keeps working as before.
local M = {}

local directions = {
  h = { herdr = "left", tmux = "TmuxNavigateLeft" },
  j = { herdr = "down", tmux = "TmuxNavigateDown" },
  k = { herdr = "up", tmux = "TmuxNavigateUp" },
  l = { herdr = "right", tmux = "TmuxNavigateRight" },
}

local function in_herdr()
  return vim.env.HERDR_PANE_ID ~= nil and vim.env.TMUX == nil and not vim.g.neovide
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

function M.go(key)
  local direction = directions[key]
  if not in_herdr() then
    vim.cmd(direction.tmux)
    return
  end

  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(key)
  if vim.api.nvim_get_current_win() == win and not is_float(win) then
    vim.system({ "herdr", "pane", "focus", "--pane", vim.env.HERDR_PANE_ID, "--direction", direction.herdr })
  end
end

return M
