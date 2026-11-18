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

-- open the panel with this project's databases
function M.toggle()
  local list = M.connections()
  if not vim.deep_equal(list, vim.g.dbs or {}) then
    vim.g.dbs = list
    vim.fn["db_ui#reset_state"]()
  end
  vim.cmd("DBUIToggle")
end

return M
