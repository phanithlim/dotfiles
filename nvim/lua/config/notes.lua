local function vault_root()
  return vim.fs.root(0, ".obsidian") or vim.fn.expand("%:p:h")
end

local function backlinks()
  local name = vim.pesc(vim.fn.expand("%:t:r")):gsub("%%", "\\")
  Snacks.picker.grep({
    title = "Backlinks",
    cwd = vault_root(),
    live = false,
    regex = true,
    glob = "*.md",
    search = "\\[\\[" .. name .. "(\\]\\]|\\||#)|\\]\\(([^)]*/)?" .. name .. "\\.md",
  })
end

local function new_note()
  vim.ui.input({ prompt = "New note: " }, function(name)
    if not name or name == "" then
      return
    end
    local path = vim.fn.expand("%:p:h") .. "/" .. name:gsub("%.md$", "") .. ".md"
    local is_new = vim.fn.filereadable(path) == 0
    vim.cmd.edit(vim.fn.fnameescape(path))
    if is_new then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. name:gsub("%.md$", ""), "", "" })
      vim.api.nvim_win_set_cursor(0, { 3, 0 })
    end
  end)
end

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new, count = line:gsub("^(%s*[-*+] )%[ %]", "%1[x]")
  if count == 0 then
    new, count = line:gsub("^(%s*[-*+] )%[[xX]%]", "%1[ ]")
  end
  if count > 0 then
    vim.api.nvim_set_current_line(new)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    local function map(key, fn, desc)
      vim.keymap.set("n", key, fn, { buffer = args.buf, desc = desc })
    end
    map("<leader>nb", backlinks, "Note Backlinks")
    map("<leader>nn", new_note, "New Note")
    map("<leader>nt", toggle_checkbox, "Toggle Checkbox")
  end,
})
