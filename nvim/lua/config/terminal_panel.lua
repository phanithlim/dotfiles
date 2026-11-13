local M = {}

local colors_file = vim.fn.expand("~/.local/state/omarchy/current/theme/colors.toml")

local function theme_background()
  if vim.fn.filereadable(colors_file) == 0 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(colors_file)) do
    local value = line:match('^%s*background%s*=%s*"#(%x+)"')
    if value then
      return tonumber(value, 16)
    end
  end
end

local function darken(color, amount)
  local r = math.floor(bit.rshift(color, 16) * (1 - amount))
  local g = math.floor(bit.band(bit.rshift(color, 8), 0xff) * (1 - amount))
  local b = math.floor(bit.band(color, 0xff) * (1 - amount))
  return bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
end

local function fg(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
end

local function set_highlights()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or theme_background()
  local panel_bg = bg and darken(bg, 0.25) or nil
  vim.api.nvim_set_hl(0, "TermPanel", { bg = panel_bg })
  local accent = fg("Function") or fg("Title")
  vim.api.nvim_set_hl(0, "TermPanelHeader", { fg = fg("Normal"), bg = panel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelHeaderNC", { fg = fg("Comment"), bg = panel_bg })
  vim.api.nvim_set_hl(0, "TermPanelBadge", { fg = panel_bg, bg = accent, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelBadgeNC", { fg = panel_bg, bg = fg("Comment"), bold = true })
  vim.api.nvim_set_hl(0, "TermPanelDim", { fg = fg("Comment"), bg = panel_bg })
  vim.api.nvim_set_hl(0, "TermPanelRun", { fg = fg("DiagnosticWarn"), bg = panel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelOk", { fg = fg("DiagnosticOk") or fg("String"), bg = panel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelErr", { fg = fg("DiagnosticError"), bg = panel_bg, bold = true })
  vim.api.nvim_set_hl(0, "TermPanelTab", { fg = fg("Comment"), bg = panel_bg })
  vim.api.nvim_set_hl(0, "TermPanelTabActive", { fg = fg("Normal"), bg = bg, bold = true })
end

local shells = { sh = true, bash = true, zsh = true, fish = true, nu = true }

local function escape(text)
  return (text:gsub("%%", "%%%%"))
end

local function shorten(text, max)
  return #text > max and (text:sub(1, max - 1) .. "…") or text
end

-- label, dir and whether the terminal is a plain shell (vs. a task command)
local function info(buf)
  -- terminal buffers are named term://<cwd>//<pid>:<cmd>
  local cwd, cmd = vim.api.nvim_buf_get_name(buf):match("^term://(.-)//%d+:(.*)$")
  -- the buffer name drops the args of list commands; snacks keeps the full one
  local snacks = vim.b[buf].snacks_terminal
  if snacks and snacks.cmd then
    cmd = type(snacks.cmd) == "table" and table.concat(snacks.cmd, " ") or snacks.cmd
    cwd = snacks.cwd or cwd
  end
  local dir = vim.fn.fnamemodify(vim.fn.expand(cwd or vim.fn.getcwd()), ":p:h:t")
  cmd = vim.trim(cmd or vim.o.shell)
  local prog = vim.fn.fnamemodify(cmd:match("^%S+") or "", ":t")
  local is_shell = shells[prog] ~= nil and not cmd:find("%s%-c%s")
  local label = is_shell and prog or (prog .. cmd:gsub("^%S+", "", 1))
  return label, dir, is_shell
end

-- compact tab name: program + non-flag args, paths shortened ("gradlew run", "java Main.java")
local function tab_name(buf)
  local words = {}
  for word in info(buf):gmatch("%S+") do
    if not word:find("^%-") then
      table.insert(words, vim.fn.fnamemodify(word, ":t"))
    end
  end
  return table.concat(words, " ")
end

-- snacks terminals in creation order; each one is a tab of the panel
local function tabs()
  local list = Snacks.terminal.list()
  table.sort(list, function(a, b) return a.buf < b.buf end)
  return list
end

local function status(buf)
  local code = vim.b[buf].term_exit
  if code == nil then
    return "%#TermPanelRun#󰑮 running "
  elseif code == 0 then
    return "%#TermPanelOk# done "
  end
  return "%#TermPanelErr# exit " .. code .. " "
end

-- winbar: [ 󰆍 TERMINAL ] [1 bash] [2 gradlew run]          <exit status>
function M.title()
  local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local active = win == vim.api.nvim_get_current_win()
  local label, _, is_shell = info(buf)

  local parts = { active and "%#TermPanelBadge#" or "%#TermPanelBadgeNC#", " 󰆍 TERMINAL ", "%#TermPanelDim# " }
  local list = tabs()
  if #list <= 1 then
    table.insert(parts, (active and "%#TermPanelHeader#" or "%#TermPanelHeaderNC#") .. " " .. escape(shorten(label, 60)) .. " ")
  else
    for i, t in ipairs(list) do
      local hl = t.buf == buf and (active and "%#TermPanelTabActive#" or "%#TermPanelHeaderNC#") or "%#TermPanelTab#"
      table.insert(parts, ("%%%d@v:lua.TermPanelClick@%s %d %s %%X"):format(t.buf, hl, i, escape(shorten(tab_name(t.buf), 24))))
    end
  end
  local hint = vim.b[buf].term_hint and ("%#TermPanelDim#" .. vim.b[buf].term_hint .. "  ") or ""
  vim.list_extend(parts, { "%=", is_shell and "" or (hint .. status(buf)) })
  return table.concat(parts)
end

local function hide_visible()
  for _, t in ipairs(tabs()) do
    if t:win_valid() then
      t:hide()
    end
  end
end

-- show the newest output; leave a window alone while you select text in it
local function follow(buf)
  local cur, mode = vim.api.nvim_get_current_win(), vim.api.nvim_get_mode().mode
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    if not (win == cur and mode:find("^[vV\22]")) then
      pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(buf), 0 })
    end
  end
end

-- keep a running terminal at the end of its output, wherever the cursor was moved
local function auto_follow(buf)
  local pending = false
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      if vim.b[buf].term_exit ~= nil then
        return true -- job ended: stop watching
      end
      if not pending then
        pending = true
        vim.defer_fn(function()
          pending = false
          if vim.api.nvim_buf_is_valid(buf) then
            follow(buf)
          end
        end, 30)
      end
    end,
  })
end

local function show(t)
  hide_visible()
  t:show():focus()
  if vim.b[t.buf].term_exit == nil then
    follow(t.buf) -- still running: back to the newest output
  end
end

-- open a terminal as a new tab instead of stacking another split
function M.open(cmd, opts)
  hide_visible()
  local id = 0
  for _, t in ipairs(tabs()) do
    id = math.max(id, vim.b[t.buf].snacks_terminal.id or 0)
  end
  return Snacks.terminal.open(cmd, vim.tbl_extend("force", { count = id + 1 }, opts or {}))
end

function M.new()
  M.open(nil, { cwd = LazyVim.root() })
end

function M.cycle(step)
  local list = tabs()
  local cur = vim.api.nvim_get_current_buf()
  for i, t in ipairs(list) do
    if t.buf == cur then
      return show(list[(i - 1 + step) % #list + 1])
    end
  end
end

function M.go(n)
  local t = tabs()[n]
  if t then
    show(t)
  end
end

function M.close()
  local list = tabs()
  local cur = vim.api.nvim_get_current_buf()
  for i, t in ipairs(list) do
    if t.buf == cur then
      -- killing the job on purpose exits with -1; drop snacks' "exited with code" warning
      for _, au in ipairs(vim.api.nvim_get_autocmds({ event = "TermClose", buffer = t.buf })) do
        vim.api.nvim_del_autocmd(au.id)
      end
      t:close()
      local next_tab = list[i + 1] or list[i - 1]
      if next_tab then
        show(next_tab)
      end
      return
    end
  end
end

local last_buf

-- <C-/>: focus the panel, hide it when already focused, or reopen the last tab
function M.toggle()
  local visible = vim.tbl_filter(function(t) return t:win_valid() end, tabs())
  if #visible > 0 then
    if vim.bo.buftype ~= "terminal" then
      return visible[1]:focus()
    end
    last_buf = vim.api.nvim_get_current_buf()
    for _, t in ipairs(visible) do
      t:hide()
    end
    return
  end
  -- reopen a shell; task tabs (build, test, ...) are reached with <A-1..9>
  local shells = vim.tbl_filter(function(t) return select(3, info(t.buf)) end, tabs())
  for _, t in ipairs(shells) do
    if t.buf == last_buf then
      return show(t)
    end
  end
  if #shells > 0 then
    return show(shells[#shells])
  end
  M.new()
end

_G.TermPanelClick = function(buf)
  for _, t in ipairs(tabs()) do
    if t.buf == buf then
      return show(t)
    end
  end
end

local function tab_keys(buf)
  local function map(lhs, fn, desc)
    vim.keymap.set({ "n", "t" }, lhs, fn, { buffer = buf, desc = desc })
  end
  -- Alt keys, or Ctrl+Space then the letter (Alt is hard to reach on some keyboards)
  for _, prefix in ipairs({ "<A-%s>", "<C-Space>%s" }) do
    map(prefix:format("t"), M.new, "Terminal: new tab")
    map(prefix:format("x"), M.close, "Terminal: close tab")
    map(prefix:format("l"), function() M.cycle(1) end, "Terminal: next tab")
    map(prefix:format("h"), function() M.cycle(-1) end, "Terminal: previous tab")
    for n = 1, 9 do
      map(prefix:format(n), function() M.go(n) end, "Terminal: tab " .. n)
    end
  end
end

local winhighlight = table.concat({
  "Normal:TermPanel",
  "NormalNC:TermPanel",
  "EndOfBuffer:TermPanel",
  "SignColumn:TermPanel",
  "WinBar:TermPanelHeader",
  "WinBarNC:TermPanelHeaderNC",
}, ",")

local function style(win)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "terminal" then
    return
  end
  vim.wo[win].winhighlight = winhighlight
  vim.wo[win].winbar = "%{%v:lua.require'config.terminal_panel'.title()%}"
  vim.wo[win].signcolumn = "yes:1"
end

function M.setup()
  local group = vim.api.nvim_create_augroup("terminal_panel", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    callback = function(args)
      vim.b[args.buf].term_exit = vim.v.event.status
      vim.schedule(function() vim.cmd("redrawstatus!") end)
    end,
  })
  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function(args)
      tab_keys(args.buf)
      auto_follow(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
          style(win)
        end
      end)
    end,
  })
  set_highlights()
end

return M
