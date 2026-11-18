local M = {}

local colors_file = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")

local function read_colors()
  local colors = {}
  if vim.fn.filereadable(colors_file) == 0 then
    return colors
  end
  for _, line in ipairs(vim.fn.readfile(colors_file)) do
    local key, value = line:match('^%s*([%w_]+)%s*=%s*"(#%x+)"')
    if key then
      colors[key] = value
    end
  end
  return colors
end

local function apply()
  local c = read_colors()
  if not c.foreground then
    return
  end
  local palette = {
    c.lighter_background, c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.light_foreground,
    c.muted, c.bright_red, c.bright_green, c.bright_yellow, c.bright_blue, c.bright_magenta, c.bright_cyan, c.foreground,
  }
  for i, color in ipairs(palette) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      vim.schedule(apply)
    end,
  })
end

return M
