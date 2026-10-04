local jdtls = require("jdtls")

local DEFAULT_PROFILE = "dev"
local sdkman_base     = vim.fn.expand("~/.sdkman/candidates/java/")

local profile_java = {
  dev        = "17",
  native     = "21",
  nativeTest = "21",
}

local function active_profile()
  return vim.g.java_maven_profile or DEFAULT_PROFILE
end

local function sdkman_current_version()
  return vim.trim(vim.fn.system("readlink " .. sdkman_base .. "current | xargs basename 2>/dev/null"))
end

local function sdkman_installed_versions()
  local dirs = vim.fn.glob(sdkman_base .. "*/", false, true)
  local versions = {}
  for _, d in ipairs(dirs) do
    local name = vim.fn.fnamemodify(d, ":h:t")
    if name ~= "current" then
      table.insert(versions, name)
    end
  end
  table.sort(versions)
  return versions
end

local function build_runtimes()
  local result = {}
  local dirs = vim.fn.glob(sdkman_base .. "*/", false, true)
  for _, d in ipairs(dirs) do
    local name = vim.fn.fnamemodify(d, ":h:t")
    if name ~= "current" then
      local major = name:match("^(%d+)")
      table.insert(result, {
        name = "JavaSE-" .. (major or "21"),
        path = sdkman_base .. name,
      })
    end
  end
  return result
end

local function workspace_dir()
  local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  return vim.fn.expand("~/.cache/jdtls/workspace/")
    .. project .. "-" .. active_profile() .. "-" .. sdkman_current_version()
end

local function start_jdtls()
  local config = {
    cmd = { "jdtls", "-data", workspace_dir() },
    root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" }),
    settings = {
      java = {
        format = {
          enabled = true,
          settings = {
            url = vim.fn.expand("~/.config/nvim/java-formatter.xml"),
            profile = "NoWrap",
          },
        },
        import = {
          maven = {
            enabled = true,
            activeProfiles = { active_profile() },
          },
        },
        configuration = {
          runtimes = build_runtimes(),
          updateBuildConfiguration = "automatic",
        },
        inlayHints = {
          parameterNames = { enabled = "all" },
        },
      },
    },
    init_options = { bundles = {} },
  }
  jdtls.start_or_attach(config)
end

start_jdtls()

vim.notify(
  "jdtls  profile: " .. active_profile() .. "  java: " .. sdkman_current_version(),
  vim.log.levels.INFO
)

local function parse_dotenv(path)
  local env = {}
  local f = io.open(path, "r")
  if not f then return env end
  for line in f:lines() do
    local trimmed = vim.trim(line)
    if trimmed ~= "" and not vim.startswith(trimmed, "#") then
      local key, value = trimmed:match("^([%w_]+)=(.*)$")
      if key then
        value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        env[key] = value
      end
    end
  end
  f:close()
  return env
end

require("dap").listeners.on_config["java_dotenv"] = function(config)
  if config.type == "java" then
    local root = config.cwd
      or vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" })
      or vim.fn.getcwd()
    local dotenv = root .. "/.env"
    if vim.loop.fs_stat(dotenv) then
      config.env = vim.tbl_extend("keep", config.env or {}, parse_dotenv(dotenv))
    end
  end
  return config
end

vim.api.nvim_create_user_command("JdtProfile", function(args)
  local profiles = vim.tbl_keys(profile_java)
  table.sort(profiles)

  local function switch(selected)
    vim.g.java_maven_profile = selected
    vim.notify("Profile → " .. selected .. "\nRestarting...", vim.log.levels.INFO)
    vim.cmd("JdtWipeDataAndRestart")
  end

  if args.args ~= "" then switch(args.args); return end

  vim.ui.select(profiles, {
    prompt = "Select Maven profile:",
    format_item = function(item)
      return item == active_profile() and item .. "  ✓" or item
    end,
  }, function(selected)
    if selected then switch(selected) end
  end)
end, {
  nargs = "?",
  complete = function() return vim.tbl_keys(profile_java) end,
  desc = "Switch Maven profile",
})

vim.api.nvim_create_user_command("JdtJava", function(args)
  local versions = sdkman_installed_versions()
  local cur = sdkman_current_version()

  local function switch(ver)
    local cmd = string.format(
      "bash -c 'export SDKMAN_DIR=%s && source %s/bin/sdkman-init.sh && sdk use java %s'",
      vim.fn.expand("~/.sdkman"),
      vim.fn.expand("~/.sdkman"),
      ver
    )
    vim.fn.system(cmd)
    vim.notify("Java → " .. ver .. "\nRestarting...", vim.log.levels.INFO)
    vim.cmd("JdtWipeDataAndRestart")
  end

  if args.args ~= "" then switch(args.args); return end

  vim.ui.select(versions, {
    prompt = "Select Java version:",
    format_item = function(ver)
      return ver == cur and ver .. "  ✓" or ver
    end,
  }, function(selected)
    if selected then switch(selected) end
  end)
end, {
  nargs = "?",
  complete = function() return sdkman_installed_versions() end,
  desc = "Switch Java version",
})

vim.api.nvim_create_user_command("JdtStatus", function()
  vim.notify(string.format(
    "profile: %s\njava:    %s",
    active_profile(),
    sdkman_current_version()
  ), vim.log.levels.INFO)
end, { desc = "Show jdtls status" })
