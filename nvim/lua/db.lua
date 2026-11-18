-- database panel: find the project's databases, like IntelliJ's Data Sources
local M = {}

-- KEY=value lines from a .env file
local function read_env(file, env)
  if vim.uv.fs_stat(file) == nil then
    return
  end
  for _, line in ipairs(vim.fn.readfile(file)) do
    local key, value = line:match("^%s*export%s+([%w_]+)%s*=%s*(.-)%s*$")
    if not key then
      key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
    end
    if key then
      env[key] = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
    end
  end
end

-- fill ${VAR} and ${VAR:default}
local function fill(value, env)
  if not value then
    return nil
  end
  local missing = false
  value = value:gsub("%${([%w_.]+):?([^}]*)}", function(name, default)
    local found = env[name] or vim.env[name]
    if found == nil and default == "" then
      missing = true
    end
    return found or default
  end)
  return not missing and value ~= "" and value or nil
end

-- datasource url, username and password from a .properties or .yml file
local function read_spring(file)
  local found = {}
  local in_datasource = false
  for _, line in ipairs(vim.fn.readfile(file)) do
    local key, value = line:match("^%s*spring%.datasource%.([%w-]+)%s*[=:]%s*(.-)%s*$")
    if key then
      found[key] = value
    elseif line:match("^%s*datasource:%s*$") then
      in_datasource = true
    elseif in_datasource then
      key, value = line:match("^%s+([%w-]+):%s*(.-)%s*$")
      if key and value ~= "" then
        found[key] = value:gsub('^"(.*)"$', "%1")
      elseif line:match("^%S") then
        in_datasource = false
      end
    end
  end
  return found.url and found or nil
end

local function encode(text)
  return (text:gsub("[^%w%-._~]", function(c) return ("%%%02X"):format(c:byte()) end))
end

-- jdbc:postgresql://host/db + user + password -> postgresql://user:password@host/db
local function to_url(jdbc, user, password)
  local url = jdbc:gsub("^jdbc:", "")
  if not url:find("^%a+://") then
    return nil
  end
  if user and not url:find("://[^/]*@") then
    local login = encode(user) .. (password and ":" .. encode(password) or "")
    url = url:gsub("://", "://" .. login .. "@", 1)
  end
  return url
end

-- all databases of the current project
function M.connections()
  local root = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "package.json" }) or vim.fn.getcwd()
  local project = vim.fn.fnamemodify(root, ":t")
  local env = {}
  read_env(root .. "/.env", env)
  read_env(root .. "/.secrets/.env", env)

  local list, seen = {}, {}
  local function add(name, url)
    if url and not seen[url] then
      seen[url] = true
      list[#list + 1] = { name = name, url = url }
    end
  end

  if env.DATABASE_URL then
    add(project, to_url(env.DATABASE_URL))
  end

  local files = vim.fn.systemlist({ "rg", "--files", "-g", "**/src/main/resources/application*", root })
  table.sort(files)
  for _, file in ipairs(vim.v.shell_error == 0 and files or {}) do
    local ds = read_spring(file)
    local url = ds and fill(ds.url, env)
    if url then
      local profile = vim.fn.fnamemodify(file, ":t:r"):match("^application%-(.+)$")
      add(project .. (profile and " (" .. profile .. ")" or ""), to_url(url, fill(ds.username, env), fill(ds.password, env)))
    end
  end
  return list
end

-- give the panel this project's databases; saved queries go to the project's .sql folder
function M.load()
  require("lazy").load({ plugins = { "vim-dadbod-ui" } })
  -- hide Postgres' own schemas
  vim.g.db_ui_hide_schemas = { "^pg_", "^information_schema$" }
  -- extra table actions; :id asks for a value
  vim.g.db_ui_table_helpers = {
    postgresql = {
      ["Last 50"] = 'select * from {optional_schema}"{table}" order by 1 desc limit 50',
      ["Find by id"] = 'select * from {optional_schema}"{table}" where id = :id',
    },
  }
  M.default_save = M.default_save or vim.g.db_ui_save_location
  local root = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "package.json" }) or vim.fn.getcwd()
  local save = vim.fn.isdirectory(root .. "/.sql") == 1 and root .. "/.sql" or M.default_save
  local list = M.connections()
  if not vim.deep_equal(list, vim.g.dbs or {}) or save ~= vim.g.db_ui_save_location then
    vim.g.dbs = list
    vim.g.db_ui_save_location = save
    vim.fn["db_ui#reset_state"]()
  end
end

-- the database lives in its own tab: open it, or close it and go back to the code
function M.toggle()
  if M.tab and vim.api.nvim_tabpage_is_valid(M.tab) then
    if vim.api.nvim_get_current_tabpage() ~= M.tab then
      return vim.api.nvim_set_current_tabpage(M.tab)
    end
    -- remember the open query so it comes back next time
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(M.tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.b[buf].dbui_db_key_name then
        M.last_query = buf
      end
    end
    M.tab = nil
    return vim.cmd("tabclose")
  end

  M.load()
  vim.cmd("tabnew")
  M.tab = vim.api.nvim_get_current_tabpage()
  if M.last_query and vim.api.nvim_buf_is_valid(M.last_query) then
    vim.api.nvim_win_set_buf(0, M.last_query)
  else
    vim.bo.bufhidden = "wipe"
  end
  vim.cmd("DBUI")
end

-- first and last line of the SQL statement under the cursor
local function statement_range()
  local row = vim.fn.line(".") - 1
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "sql")
  if ok and parser then
    for node in parser:parse()[1]:root():iter_children() do
      local first, _, last = node:range()
      if node:type() == "statement" and first <= row and row <= last then
        return first + 1, last + 1
      end
    end
  end
  -- no statement found: use the block between blank lines
  return vim.fn.search("^\\s*$\\|\\%^", "bnW") + 1, vim.fn.search("^\\s*$\\|\\%$", "nW")
end

-- close the result window, or open the last result again
function M.toggle_result()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "dbout" then
      -- keep only the newest result
      if M.last_result and M.last_result ~= buf and vim.api.nvim_buf_is_valid(M.last_result) then
        vim.api.nvim_buf_delete(M.last_result, { force = true })
      end
      M.last_result = buf
      vim.bo[buf].bufhidden = "hide"
      return vim.api.nvim_win_close(win, false)
    end
  end
  if M.last_result and vim.api.nvim_buf_is_valid(M.last_result) then
    local win = vim.api.nvim_get_current_win()
    vim.cmd("botright sbuffer " .. M.last_result)
    vim.api.nvim_set_current_win(win)
  else
    vim.notify("No result yet", vim.log.levels.INFO)
  end
end

-- run the statement under the cursor, or the selected lines
function M.run(visual)
  if not vim.b.dbui_db_key_name then
    -- a plain .sql file: pick which database to run it on
    M.load()
    vim.cmd("DBUIFindBuffer")
    if not vim.b.dbui_db_key_name then
      return
    end
  end
  if visual then
    vim.cmd("normal! \27")
  else
    local first, last = statement_range()
    vim.cmd(("normal! %dGV%dG\27"):format(first, last))
  end
  vim.api.nvim_feedkeys(vim.keycode("gv<Plug>(DBUI_ExecuteQuery)"), "m", false)
end

return M
