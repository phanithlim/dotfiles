-- tmux-style Ctrl-b prefix for Neovide, mirroring ~/.config/tmux/tmux.conf so the
-- same keystrokes work in Ghostty+tmux and in Neovide. Like tmux, the prefix waits
-- for the next key with no timeout; tabs stand in for tmux windows.
local M = {}

local function tab(cmd)
  return function()
    pcall(vim.cmd, cmd)
  end
end

local actions = {
  c = tab("tabnew"),
  ["\t"] = tab("tabnext #"),
  ["|"] = tab("vsplit"),
  _ = tab("split"),
  x = tab("close"),
  X = tab("tabclose"),
  h = tab("wincmd h"),
  j = tab("wincmd j"),
  k = tab("wincmd k"),
  l = tab("wincmd l"),
  H = tab("vertical resize -5"),
  L = tab("vertical resize +5"),
  J = tab("resize +5"),
  K = tab("resize -5"),
  ["<"] = tab("-tabmove"),
  [">"] = tab("+tabmove"),
  ["\16"] = tab("tabprevious"), -- Ctrl-p
  ["\14"] = tab("tabnext"), -- Ctrl-n
  g = function() Snacks.lazygit() end,
  p = function() Snacks.terminal.focus(nil, { cwd = LazyVim.root() }) end,
  f = function() Snacks.picker.projects() end,
  S = function() require("persistence").select() end,
}
for i = 1, 9 do
  actions[tostring(i)] = tab("tabnext " .. i)
end

local function prefix()
  -- Keep noice's <C-b>: scroll an open hover/signature popup.
  local has_noice, noice_lsp = pcall(require, "noice.lsp")
  if has_noice and vim.api.nvim_get_mode().mode == "n" and noice_lsp.scroll(-4) then
    return
  end
  local ok, key = pcall(vim.fn.getcharstr)
  if ok and actions[key] then
    actions[key]()
  end
end

function M.setup()
  -- noice.nvim's normal-mode <C-b> is disabled in lua/plugins/neovide.lua.
  vim.keymap.set({ "n", "t" }, "<C-b>", prefix, { desc = "tmux-style prefix" })
end

return M
