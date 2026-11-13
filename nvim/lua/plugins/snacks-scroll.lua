-- j/k and the arrow keys move one line, so they never animate. Next to a code lens
-- (or any virtual line) one k can scroll the view 2 rows, which started an
-- animation; while it ran, it kept resetting the cursor and ate held-k repeats.
local line_keys = {}
for _, key in ipairs({ "j", "k", "<Down>", "<Up>" }) do
  line_keys[vim.keycode(key)] = true
end
local by_line_key = false
vim.on_key(function(_, typed)
  if typed and typed ~= "" then
    by_line_key = line_keys[typed] or false
  end
end, vim.api.nvim_create_namespace("snacks_scroll_line_keys"))

return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = not vim.g.neovide,
      -- slow enough for the eye to follow
      animate = {
        duration = { step = 10, total = 250 },
        easing = "outQuad",
      },
      -- holding or repeating a scroll key (default 50ms felt like a jump)
      animate_repeat = {
        delay = 100,
        duration = { step = 10, total = 120 },
        easing = "outQuad",
      },
      -- snacks' default filter, plus: not for j/k/arrows
      filter = function(buf)
        return not by_line_key
          and vim.g.snacks_scroll ~= false
          and vim.b[buf].snacks_scroll ~= false
          and vim.bo[buf].buftype ~= "terminal"
      end,
    },
  },
}
