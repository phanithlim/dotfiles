local colors_file = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")
local palette

local function load_palette()
  local c = {}
  if vim.fn.filereadable(colors_file) == 1 then
    for _, line in ipairs(vim.fn.readfile(colors_file)) do
      local key, value = line:match('^%s*([%w_]+)%s*=%s*"(#%x+)"')
      if key then
        c[key] = value
      end
    end
  end
  palette = {
    crust = c.darker_background or "#11111b",
    surface = c.lighter_background or "#313244",
    text = c.foreground or "#cdd6f4",
    dim = c.dark_foreground or "#6c7086",
    red = c.red or "#f38ba8",
    yellow = c.yellow or "#f9e2af",
  }
end

local LEFT, RIGHT = "\u{e0b6}", "\u{e0b4}"

local function render(props)
  local p = palette
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  if name == "" then
    name = "[No Name]"
  end
  local icon, icon_color = require("nvim-web-devicons").get_icon_color(name)
  local icon_bg = props.focused and (icon_color or p.text) or p.dim

  local text = { { " " .. name, gui = props.focused and "bold" or "none" } }
  if vim.bo[props.buf].modified then
    table.insert(text, { " \u{25cf}", guifg = p.yellow })
  end
  local errors = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.WARN })
  if errors > 0 then
    table.insert(text, { " \u{f057} " .. errors, guifg = p.red })
  end
  if warnings > 0 then
    table.insert(text, { " \u{f071} " .. warnings, guifg = p.yellow })
  end
  table.insert(text, " ")

  return {
    { LEFT, guifg = icon_bg },
    { (icon or "\u{f15b}") .. " ", guifg = p.crust, guibg = icon_bg },
    { text, guifg = props.focused and p.text or p.dim, guibg = p.surface },
    { RIGHT, guifg = p.surface },
  }
end

return {
  {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      load_palette()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("incline_palette", { clear = true }),
        callback = load_palette,
      })
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 1, vertical = 1 },
        },
        highlight = {
          groups = {
            InclineNormal = { group = "Normal", default = false },
            InclineNormalNC = { group = "Normal", default = false },
          },
        },
        render = render,
      })
    end,
  },
}
