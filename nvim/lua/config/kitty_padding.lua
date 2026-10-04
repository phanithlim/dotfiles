local M = {}

local function set_padding(value, sync)
  local cmd = {
    "kitty", "@", "--to", vim.env.KITTY_LISTEN_ON,
    "set-spacing", "--match", "id:" .. vim.env.KITTY_WINDOW_ID, "padding=" .. value,
  }
  if sync then
    vim.fn.system(cmd) -- must finish before Neovim exits
  else
    vim.fn.jobstart(cmd, { detach = true })
  end
end

function M.setup()
  if vim.env.TERM ~= "xterm-kitty" or vim.env.TMUX or not vim.env.KITTY_LISTEN_ON or not vim.env.KITTY_WINDOW_ID
    or vim.fn.executable("kitty") == 0 then
    return
  end
  local group = vim.api.nvim_create_augroup("kitty_padding", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = function() set_padding("0") end,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function() set_padding("default", true) end,
  })
end

return M
