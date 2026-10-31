local M = {}

local function project()
  local buf_dir = vim.fn.expand("%:p:h")
  local root = vim.fs.root(buf_dir, { "gradlew", "mvnw", "settings.gradle", "settings.gradle.kts" })
    or vim.fs.root(buf_dir, { "pom.xml", "build.gradle", "build.gradle.kts" })
  if not root then
    return nil
  end
  local function has(name)
    return vim.uv.fs_stat(vim.fs.joinpath(root, name)) ~= nil
  end
  local function read(name)
    return has(name) and table.concat(vim.fn.readfile(vim.fs.joinpath(root, name)), "\n") or ""
  end

  if has("gradlew") or has("build.gradle") or has("build.gradle.kts") or has("settings.gradle.kts") then
    local files = { root .. "/gradle/libs.versions.toml" }
    for _, pattern in ipairs({ "/*.gradle*", "/*/*.gradle*", "/build-logic/src/main/*/*.gradle*" }) do
      vim.list_extend(files, vim.fn.glob(root .. pattern, false, true))
    end
    local build = ""
    for _, file in ipairs(files) do
      if vim.uv.fs_stat(file) then
        build = build .. table.concat(vim.fn.readfile(file), "\n")
      end
    end
    return {
      root = root,
      tool = "gradle",
      bin = has("gradlew") and vim.fs.joinpath(root, "gradlew") or "gradle",
      spring = build:find("org.springframework.boot", 1, true) ~= nil,
      application = build:find("application", 1, true) ~= nil,
    }
  end

  local pom = read("pom.xml")
  return {
    root = root,
    tool = "maven",
    bin = has("mvnw") and vim.fs.joinpath(root, "mvnw") or "mvn",
    spring = pom:find("spring-boot", 1, true) ~= nil,
    pom = pom,
  }
end

local function current_class()
  if vim.bo.filetype ~= "java" then
    return nil
  end
  local name = vim.fn.expand("%:t:r")
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do
    local pkg = line:match("^%s*package%s+([%w_.]+)%s*;")
    if pkg then
      return pkg .. "." .. name
    end
  end
  return name
end

local function read_dotenv(file)
  local env = {}
  if not vim.uv.fs_stat(file) then
    return env
  end
  for _, line in ipairs(vim.fn.readfile(file)) do
    local key, value = vim.trim(line):match("^export%s+([%w_]+)=(.*)$")
    if not key then
      key, value = vim.trim(line):match("^([%w_]+)=(.*)$")
    end
    if key then
      env[key] = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
    end
  end
  return env
end

local function project_env(root, profiles)
  local env = read_dotenv(root .. "/.env")
  for profile in (profiles or ""):gmatch("[^,]+") do
    env = vim.tbl_extend("force", env, read_dotenv(root .. "/.secrets/" .. profile .. "/.env"))
  end
  for key, value in pairs(env) do
    local rel = value:match("^file:([^/].*)$")
    if rel and vim.uv.fs_stat(root .. "/" .. rel) then
      env[key] = "file:" .. root .. "/" .. rel
    end
  end
  return next(env) and env or nil
end

local function open_term(cmd, cwd, key, env)
  key = cwd .. ":" .. (key or table.concat(cmd, " "))
  for _, t in ipairs(Snacks.terminal.list()) do
    if vim.b[t.buf].java_task == key then
      t:close()
    end
  end
  local term = require("config.terminal_panel").open(cmd, { cwd = cwd, env = env, interactive = false })
  if term and term.buf then
    vim.b[term.buf].java_task = key
  end
end

local spring_profile = {}

local function spring_profiles(root)
  local dirs = vim.list_extend({ root .. "/src/main/resources" }, vim.fn.glob(root .. "/*/src/main/resources", false, true))
  local seen, list = {}, {}
  for _, dir in ipairs(dirs) do
    for _, f in ipairs(vim.fn.glob(dir .. "/application-*", false, true)) do
      local name = vim.fn.fnamemodify(f, ":t"):match("^application%-(.+)%.%a+$")
      if name and not seen[name] then
        seen[name] = true
        table.insert(list, name)
      end
    end
  end
  table.sort(list)
  return list
end

local function maven_base(p)
  local cmd = { p.bin, "-B" }
  local profile = vim.g.java_maven_profile or "dev"
  if p.pom:find("<id>" .. profile .. "</id>", 1, true) then
    table.insert(cmd, "-P" .. profile)
  end
  return cmd
end

local function run_task(kind)
  local p = project()
  if not p then
    return Snacks.notify.warn("Not in a Maven or Gradle project")
  end
  vim.cmd("silent! wall")

  local class = current_class()
  local args

  if p.tool == "gradle" then
    if kind == "run" then
      if p.spring then
        args = { "bootRun" }
        if spring_profile[p.root] then
          table.insert(args, "--args=--spring.profiles.active=" .. spring_profile[p.root])
        end
      elseif p.application then
        args = { "run" }
      else
        return Snacks.notify.warn("Add the `application` plugin and `mainClass` to build.gradle(.kts)")
      end
    elseif kind == "build" then
      args = { "build" }
    elseif kind == "clean" then
      args = { "clean" }
    elseif kind == "test" then
      args = { "test" }
    elseif kind == "test_class" then
      if not class then
        return Snacks.notify.warn("Not a Java file")
      end
      args = { "test", "--tests", class }
    end
    open_term(vim.list_extend({ p.bin, "--console=plain" }, args), p.root, kind, project_env(p.root, spring_profile[p.root]))
    return
  end

  if kind == "run" then
    if p.spring then
      args = { "spring-boot:run" }
      if spring_profile[p.root] then
        table.insert(args, "-Dspring-boot.run.profiles=" .. spring_profile[p.root])
      end
    elseif class then
      args = { "compile", "exec:java", "-Dexec.mainClass=" .. class }
    else
      return Snacks.notify.warn("Open the Java file with the main method to run")
    end
  elseif kind == "build" then
    args = { "package" }
  elseif kind == "clean" then
    args = { "clean" }
  elseif kind == "test" then
    args = { "test" }
  elseif kind == "test_class" then
    if not class then
      return Snacks.notify.warn("Not a Java file")
    end
    args = { "test", "-Dtest=" .. class:match("[^.]+$"), "-Dsurefire.failIfNoSpecifiedTests=false" }
  end
  open_term(vim.list_extend(maven_base(p), args), p.root, kind, project_env(p.root, spring_profile[p.root]))
end

local function run_file()
  if vim.bo.filetype ~= "java" then
    return Snacks.notify.warn("Not a Java file")
  end
  vim.cmd("silent! write")
  local file = vim.api.nvim_buf_get_name(0)
  open_term({ "java", file }, vim.fn.fnamemodify(file, ":h"))
end

local function pick_spring_profile()
  local p = project()
  if not p then
    return Snacks.notify.warn("Not in a Maven or Gradle project")
  end
  local current = spring_profile[p.root]
  local items = vim.list_extend({ "(default)" }, spring_profiles(p.root))
  if current and not vim.tbl_contains(items, current) then
    table.insert(items, current)
  end
  table.insert(items, "Custom…")

  local function set(profile)
    spring_profile[p.root] = profile
    Snacks.notify.info("Spring profile → " .. (profile or "(default)") .. "\nApplies to the next Run project (<leader>jr)")
  end

  vim.ui.select(items, {
    prompt = "Spring profile",
    format_item = function(item)
      local active = item == current or (item == "(default)" and not current)
      return active and (item .. "  ✓") or item
    end,
  }, function(choice)
    if not choice then
      return
    elseif choice == "Custom…" then
      vim.ui.input({ prompt = "Spring profiles (comma separated): ", default = current or "" }, function(input)
        input = input and input:gsub("%s", "")
        if input then
          set(input ~= "" and input or nil)
        end
      end)
    else
      set(choice ~= "(default)" and choice or nil)
    end
  end)
end

local function jdt(cmd)
  return function()
    if vim.fn.exists(":" .. cmd) ~= 2 then
      return Snacks.notify.warn("Open a Java file first (jdtls is not started)")
    end
    vim.cmd(cmd)
  end
end

local function maven_profile()
  local p = project()
  if p and p.tool ~= "maven" then
    return Snacks.notify.warn("Maven profiles only exist in Maven projects; use <leader>jp for Spring profiles")
  end
  jdt("JdtProfile")()
end

local function status()
  local p = project()
  local java = vim.uv.fs_realpath(vim.env.JAVA_HOME or vim.fn.expand("~/.sdkman/candidates/java/current"))
  local lines = { "java:    " .. (java and vim.fn.fnamemodify(java, ":t") or "?") }
  if p then
    table.insert(lines, "build:   " .. p.tool)
    if p.tool == "maven" then
      table.insert(lines, "maven:   " .. (vim.g.java_maven_profile or "dev"))
    end
    if p.spring then
      table.insert(lines, "spring:  " .. (spring_profile[p.root] or "(default)"))
    end
  end
  Snacks.notify.info(table.concat(lines, "\n"), { title = "Java" })
end

function M.setup()
  local maps = {
    { "<leader>jr", function() run_task("run") end, desc = "Run project", icon = { icon = "", color = "green" } },
    { "<leader>jf", run_file, desc = "Run current file", icon = { icon = "", color = "green" } },
    { "<leader>jb", function() run_task("build") end, desc = "Build", icon = { icon = "", color = "yellow" } },
    { "<leader>jc", function() run_task("clean") end, desc = "Clean", icon = { icon = "󰃢", color = "orange" } },
    { "<leader>jt", function() run_task("test") end, desc = "Test all", icon = { icon = "󰙨", color = "cyan" } },
    { "<leader>jT", function() run_task("test_class") end, desc = "Test current class", icon = { icon = "󰙨", color = "blue" } },
    { "<leader>jp", pick_spring_profile, desc = "Switch Spring profile", icon = { icon = "", color = "green" } },
    { "<leader>jm", maven_profile, desc = "Switch Maven profile", icon = { icon = "", color = "purple" } },
    { "<leader>jv", jdt("JdtJava"), desc = "Switch Java version", icon = { icon = "", color = "red" } },
    { "<leader>js", status, desc = "Java status", icon = { icon = "", color = "azure" } },
  }

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add(vim.list_extend({ { "<leader>j", group = "java", icon = { icon = "", color = "orange" } } }, maps))
  else
    for _, m in ipairs(maps) do
      vim.keymap.set("n", m[1], m[2], { desc = m.desc })
    end
  end
end

return M
