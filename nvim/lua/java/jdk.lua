-- Follow the project's .sdkmanrc inside Neovim, like the shell does.
local M = {}

local sdk = vim.fn.expand("~/.sdkman/candidates/java/")
local wanted_cache = {}

-- java version from the nearest .sdkmanrc, like "25.0.1-amzn", or nil
function M.wanted()
  local cwd = vim.fn.getcwd()
  if wanted_cache[cwd] == nil then
    wanted_cache[cwd] = false
    local file = vim.fs.find(".sdkmanrc", { upward = true, path = cwd })[1]
    for _, line in ipairs(file and vim.fn.readfile(file) or {}) do
      local version = line:match("^%s*java%s*=%s*(%S+)")
      if version then
        wanted_cache[cwd] = version
      end
    end
  end
  return wanted_cache[cwd] or nil
end

-- the JDK in use, like "21.0.9-amzn"
function M.current()
  local home = vim.uv.fs_realpath(vim.env.JAVA_HOME or "")
  return home and vim.fn.fnamemodify(home, ":t") or nil
end

-- point JAVA_HOME and PATH at another JDK
function M.use(home)
  local path = {}
  for dir in vim.env.PATH:gmatch("[^:]+") do
    if not dir:find(sdk, 1, true) then
      table.insert(path, dir)
    end
  end
  vim.env.JAVA_HOME = home
  vim.env.PATH = home .. "/bin:" .. table.concat(path, ":")
end

-- switch to the .sdkmanrc JDK, or back to the default
function M.follow()
  local want = M.wanted()
  local home = sdk .. (want or "current")
  if not vim.uv.fs_stat(home) then
    vim.notify("Java " .. want .. " is not installed: sdk install java " .. want, vim.log.levels.WARN)
    return
  end
  if vim.uv.fs_realpath(home) == vim.uv.fs_realpath(vim.env.JAVA_HOME or "") then
    return
  end
  M.use(home)
  vim.notify("Java " .. M.current(), vim.log.levels.INFO, { title = "JDK" })
end

-- status line: only in JVM projects
function M.show()
  if vim.b.jvm_project == nil then
    vim.b.jvm_project = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".sdkmanrc" }) ~= nil
  end
  return vim.b.jvm_project
end

function M.status()
  local current = M.current() or "?"
  return "\u{e738} " .. (current:match("^%d+") or current)
end

-- red when Neovim's Java is not the one .sdkmanrc asks for
function M.mismatch()
  local want = M.wanted()
  return want ~= nil and want ~= M.current()
end

function M.setup()
  vim.api.nvim_create_autocmd("DirChanged", { callback = M.follow })
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = ".sdkmanrc",
    callback = function()
      wanted_cache = {}
      M.follow()
    end,
  })
  M.follow()
end

return M
