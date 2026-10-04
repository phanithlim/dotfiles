local M = {}

local buf, win
local ns = vim.api.nvim_create_namespace("maven_panel")
local cursor_ns = vim.api.nvim_create_namespace("maven_panel_cursor")

local selectable = {}
local expanded = {}

local lifecycle_goals = {
  "clean", "validate", "compile", "test",
  "package", "verify", "install", "deploy",
}

local plugin_goals = {
  ["avro-maven-plugin"] = {
    "avro:help",
    "avro:idl-protocol",
    "avro:induce",
    "avro:protocol",
    "avro:schema",
  },
  ["kafka-schema-registry-maven-plugin"] = {
    "schema-registry:derive-schema",
    "schema-registry:download",
    "schema-registry:register",
    "schema-registry:set-compatibility",
    "schema-registry:test-compatibility",
    "schema-registry:test-local-compatibility",
    "schema-registry:validate",
  },
}

local function find_pom()
  return vim.fn.findfile("pom.xml", vim.fn.getcwd() .. ";")
end

local function xmllint_query(pom, xpath)
  return vim.fn.system(
    string.format("xmllint --xpath '%s' %s 2>/dev/null", xpath, pom)
  )
end

local function get_plugins(pom)
  local result = xmllint_query(pom,
    '//*[local-name()="plugin"]/*[local-name()="artifactId"]/text()'
  )
  local plugins, seen = {}, {}
  for name in result:gmatch("[^\n]+") do
    if not seen[name] then
      seen[name] = true
      table.insert(plugins, name)
    end
  end
  return plugins
end

local function get_dependencies(pom)
  -- get groupId:artifactId:version and optional scope
  local result = vim.fn.system(string.format([[
    xmllint --xpath '//*[local-name()="dependencies"]/*[local-name()="dependency"]' %s 2>/dev/null
  ]], pom))

  local deps = {}
  -- parse each <dependency> block
  for block in result:gmatch("<[^>]*dependency[^>]*>(.-)<[^>]*dependency[^>]*>") do
    local group   = block:match('<[^>]*groupId[^>]*>([^<]+)<') or ""
    local artifact= block:match('<[^>]*artifactId[^>]*>([^<]+)<') or ""
    local version = block:match('<[^>]*version[^>]*>([^<]+)<') or ""
    local scope   = block:match('<[^>]*scope[^>]*>([^<]+)<') or ""
    if artifact ~= "" then
      table.insert(deps, {
        label = group .. ":" .. artifact .. (version ~= "" and (":" .. version) or ""),
        scope = scope,
      })
    end
  end
  return deps
end

local function get_repositories(pom)
  local result = vim.fn.system(string.format([[
    xmllint --xpath '//*[local-name()="repositories"]/*[local-name()="repository"]' %s 2>/dev/null
  ]], pom))

  local repos = {}
  for block in result:gmatch("<[^>]*repository[^>]*>(.-)<[^>]*repository[^>]*>") do
    local id  = block:match('<[^>]*id[^>]*>([^<]+)<') or ""
    local url = block:match('<[^>]*url[^>]*>([^<]+)<') or ""
    if id ~= "" then
      table.insert(repos, { id = id, url = url })
    end
  end
  return repos
end

local function run_maven(goal)
  M.close()
  local term_buf = vim.api.nvim_create_buf(false, true)
  local term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.7),
    height = math.floor(vim.o.lines * 0.4),
    row = math.floor(vim.o.lines * 0.3),
    col = math.floor(vim.o.columns * 0.15),
    style = "minimal",
    border = "rounded",
    title = "  mvn " .. goal .. " ",
    title_pos = "center",
  })
  vim.fn.termopen("mvn " .. goal, {
    on_exit = function()
      vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(term_win) then
          vim.api.nvim_win_close(term_win, true)
        end
      end, { buffer = term_buf, silent = true })
    end,
  })
  vim.cmd("startinsert")
end

local function sep()
  return "  " .. string.rep("─", 18)
end

local function build_lines(data)
  selectable = {}
  local lines = {}
  local meta = {}

  local function add(line, m)
    table.insert(lines, line)
    table.insert(meta, m or {})
  end

  local function add_header(label)
    add("  " .. label, { type = "header" })
    add(sep(), { type = "sep" })
  end

  add("  Maven", { type = "header" })
  add("", {})

  -- Lifecycle
  add_header("Lifecycle")
  for _, goal in ipairs(lifecycle_goals) do
    local idx = #lines
    selectable[idx] = { kind = "goal", value = goal }
    add("    " .. goal, { type = "goal" })
  end

  add("", {})

  -- Plugins
  add_header("Plugins")
  if #data.plugins == 0 then
    add("    (no plugins found)", {})
  else
    for _, name in ipairs(data.plugins) do
      local has_goals = plugin_goals[name] ~= nil
      local is_expanded = expanded["plugin:" .. name]
      local prefix = has_goals and (is_expanded and "  ▾ " or "  ▸ ") or "    "
      local idx = #lines
      if has_goals then
        selectable[idx] = { kind = "plugin", value = name }
      end
      add(prefix .. name, { type = "plugin", name = name })
      if has_goals and is_expanded then
        for _, goal in ipairs(plugin_goals[name]) do
          local gidx = #lines
          selectable[gidx] = { kind = "goal", value = goal }
          add("      " .. goal, { type = "goal" })
        end
      end
    end
  end

  add("", {})

  -- Dependencies
  local dep_expanded = expanded["section:dependencies"]
  add_header("Dependencies")
  local dep_idx = #lines - 2  -- point to header line
  -- make header toggleable
  selectable[#lines - 2] = { kind = "section", value = "dependencies" }

  if dep_expanded then
    if #data.deps == 0 then
      add("    (none found)", {})
    else
      for _, dep in ipairs(data.deps) do
        add("    " .. dep.label .. (dep.scope ~= "" and (" (" .. dep.scope .. ")") or ""),
          { type = "dep", scope = dep.scope })
      end
    end
  else
    add("    " .. #data.deps .. " dependencies", { type = "hint" })
  end

  add("", {})

  -- Repositories
  local repo_expanded = expanded["section:repositories"]
  add_header("Repositories")
  selectable[#lines - 2] = { kind = "section", value = "repositories" }

  if repo_expanded then
    if #data.repos == 0 then
      add("    (none found)", {})
    else
      for _, repo in ipairs(data.repos) do
        add("    " .. repo.id, { type = "repo" })
        if repo.url ~= "" then
          add("      " .. repo.url, { type = "hint" })
        end
      end
    end
  else
    add("    " .. #data.repos .. " repositories", { type = "hint" })
  end

  add("", {})

  return lines, meta
end

local data_cache = nil

local function apply_highlights(meta)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, m in ipairs(meta) do
    local idx = i - 1
    if m.type == "header" then
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = "Title", priority = 10 })
    elseif m.type == "sep" then
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = "Comment", priority = 10 })
    elseif m.type == "plugin" then
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = "Special", priority = 10 })
    elseif m.type == "hint" then
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = "Comment", priority = 10 })
    elseif m.type == "dep" then
      local hl = m.scope == "test" and "DiagnosticHint" or "Variable"
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = hl, priority = 10 })
    elseif m.type == "repo" then
      vim.api.nvim_buf_set_extmark(buf, ns, idx, 0, { line_hl_group = "Special", priority = 10 })
    end
  end
end

local function highlight_cursor()
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  if not win or not vim.api.nvim_win_is_valid(win) then return end
  vim.api.nvim_buf_clear_namespace(buf, cursor_ns, 0, -1)
  local row = vim.api.nvim_win_get_cursor(win)[1] - 1
  if selectable[row] then
    vim.api.nvim_buf_set_extmark(buf, cursor_ns, row, 0, {
      line_hl_group = "PmenuSel",
      priority = 100,
    })
  end
end

local function refresh()
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  if not win or not vim.api.nvim_win_is_valid(win) then return end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local lines, meta = build_lines(data_cache)

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  apply_highlights(meta)

  local total = vim.api.nvim_buf_line_count(buf)
  if cursor[1] > total then
    vim.api.nvim_win_set_cursor(win, { total, cursor[2] })
  end
  highlight_cursor()
end

function M.open()
  expanded = {}
  local pom = find_pom()

  data_cache = {
    plugins = pom ~= "" and get_plugins(pom) or {},
    deps    = pom ~= "" and get_dependencies(pom) or {},
    repos   = pom ~= "" and get_repositories(pom) or {},
  }

  local lines, meta = build_lines(data_cache)

  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "maven-panel", { buf = buf })

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    anchor = "NE",
    width = 42,
    height = vim.o.lines - 4,
    row = 1,
    col = vim.o.columns,
    style = "minimal",
    border = "rounded",
    title = "  Maven ",
    title_pos = "center",
  })

  vim.api.nvim_set_option_value("cursorline", false, { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })

  apply_highlights(meta)

  -- Move to first selectable
  local first = nil
  for idx in pairs(selectable) do
    if first == nil or idx < first then first = idx end
  end
  if first then
    vim.api.nvim_win_set_cursor(win, { first + 1, 4 })
  end

  highlight_cursor()

  -- Keymaps
  vim.keymap.set("n", "q", M.close, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", M.close, { buffer = buf, silent = true })

  vim.keymap.set("n", "j", function()
    local row = vim.api.nvim_win_get_cursor(win)[1] - 1
    local total = vim.api.nvim_buf_line_count(buf)
    for next = row + 1, total - 1 do
      if selectable[next] then
        vim.api.nvim_win_set_cursor(win, { next + 1, 4 })
        break
      end
    end
    highlight_cursor()
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "k", function()
    local row = vim.api.nvim_win_get_cursor(win)[1] - 1
    for prev = row - 1, 0, -1 do
      if selectable[prev] then
        vim.api.nvim_win_set_cursor(win, { prev + 1, 4 })
        break
      end
    end
    highlight_cursor()
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(win)[1] - 1
    local sel = selectable[row]
    if not sel then return end

    if sel.kind == "goal" then
      run_maven(sel.value)
    elseif sel.kind == "plugin" then
      expanded["plugin:" .. sel.value] = not expanded["plugin:" .. sel.value]
      refresh()
      highlight_cursor()
    elseif sel.kind == "section" then
      expanded["section:" .. sel.value] = not expanded["section:" .. sel.value]
      refresh()
      highlight_cursor()
    end
  end, { buffer = buf, silent = true })

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = highlight_cursor,
  })
end

function M.close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
  buf = nil
end

function M.toggle()
  if win and vim.api.nvim_win_is_valid(win) then
    M.close()
  else
    M.open()
  end
end

return M