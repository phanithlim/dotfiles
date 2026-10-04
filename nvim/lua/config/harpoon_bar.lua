local M = {}

local function set_highlights()
  vim.api.nvim_set_hl(0, "HarpoonBarFill", { link = "TabLineFill", default = true })
  vim.api.nvim_set_hl(0, "HarpoonBarNumber", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "HarpoonBarFile", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "HarpoonBarActiveNumber", { link = "Title", default = true })
  vim.api.nvim_set_hl(0, "HarpoonBarActiveFile", { link = "Normal", default = true })
end

local function items()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then
    return {}
  end
  local list = harpoon:list()
  local result = {}
  for i = 1, list:length() do
    local item = list:get(i)
    if item and item.value ~= "" then
      table.insert(result, { index = i, value = item.value })
    end
  end
  return result
end

function M.render()
  local current = vim.api.nvim_buf_get_name(0)
  local parts = {}
  for _, item in ipairs(items()) do
    local active = vim.fn.fnamemodify(item.value, ":p") == current
    local name = vim.fn.fnamemodify(item.value, ":t")
    table.insert(parts, ("%%#%s# %d %%#%s#%s "):format(
      active and "HarpoonBarActiveNumber" or "HarpoonBarNumber",
      item.index,
      active and "HarpoonBarActiveFile" or "HarpoonBarFile",
      name:gsub("%%", "%%%%")
    ))
  end
  local line = "%#HarpoonBarFill#" .. table.concat(parts, "%#HarpoonBarNumber#·")

  local tabs = vim.fn.tabpagenr("$")
  if tabs > 1 then
    local current_tab = vim.fn.tabpagenr()
    line = line .. "%="
    for t = 1, tabs do
      line = line .. ("%%%dT%%#%s# %d %%T"):format(t, t == current_tab and "HarpoonBarActiveNumber" or "HarpoonBarNumber", t)
    end
  end
  return line
end

function M.update()
  local show = #items() > 0 or vim.fn.tabpagenr("$") > 1
  vim.o.showtabline = show and 2 or 0
  vim.cmd.redrawtabline()
end

function M.setup()
  set_highlights()
  vim.o.tabline = "%!v:lua.require'config.harpoon_bar'.render()"
  local group = vim.api.nvim_create_augroup("harpoon_bar", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd({ "TabNew", "TabClosed", "DirChanged", "BufEnter" }, {
    group = group,
    callback = function()
      vim.schedule(M.update)
    end,
  })
  M.update()
end

return M
