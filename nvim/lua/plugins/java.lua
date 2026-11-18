-- jdtls: Java language server
require("java.lens").setup()

local jdtls = {
  "mfussenegger/nvim-jdtls",
  opts = {
    jdtls = function(opts)

      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/"
      local bundles = {}

      local debug_jar = vim.fn.glob(
        mason_path .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1
      )
      if debug_jar ~= "" then
        table.insert(bundles, debug_jar)
      end

      local test_jars = vim.split(
        vim.fn.glob(mason_path .. "java-test/extension/server/*.jar", 1), "\n"
      )
      for _, jar in ipairs(test_jars) do
        local name = vim.fn.fnamemodify(jar, ":t")
        if jar ~= "" and name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
          table.insert(bundles, jar)
        end
      end

      local ok, spring_boot = pcall(require, "spring_boot")
      if ok then
        vim.list_extend(bundles, spring_boot.java_extensions())
      end

      opts.init_options = { bundles = bundles }

      -- memory and garbage collector settings from VS Code's Java extension
      vim.list_extend(opts.cmd, {
        "--jvm-arg=-Xms1g",
        "--jvm-arg=-Xmx4g",
        "--jvm-arg=-XX:+UseParallelGC",
        "--jvm-arg=-XX:GCTimeRatio=4",
        "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
        "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
      })

      local function jdk(version)
        return vim.fn.glob(vim.fn.expand("~/.sdkman/candidates/java/") .. version .. ".*", false, true)[1]
      end
      -- run jdtls itself on Java 21+, whatever JDK the project uses
      local server_jdk = jdk("25") or jdk("21")
      if server_jdk then
        vim.list_extend(opts.cmd, { "--java-executable", server_jdk .. "/bin/java" })
      end

      local runtimes = {}
      for _, v in ipairs({ "17", "21", "25" }) do
        local home = jdk(v)
        if home then
          table.insert(runtimes, { name = "JavaSE-" .. v, path = home, default = v == "21" or nil })
        end
      end

      opts.settings = {
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
              activeProfiles = { "dev" },
            },
            gradle = {
              enabled = true,
              wrapper = { enabled = true },
              -- lets Java code resolve classes from Kotlin projects (see jdtls/kotlin-classes.gradle)
              arguments = "--init-script " .. vim.fn.stdpath("config") .. "/jdtls/kotlin-classes.gradle",
              java = { home = vim.uv.fs_realpath(vim.env.JAVA_HOME or "") or jdk("21") },
              annotationProcessing = { enabled = false },
            },
          },
          configuration = {
            updateBuildConfiguration = "automatic",
            runtimes = runtimes,
          },
          referencesCodeLens = { enabled = true },
          implementationCodeLens = "all",
          inlayHints = {
            parameterNames = { enabled = "all" },
          },
          -- index the JDK and libraries once, shared by all projects
          sharedIndexes = { enabled = "on" },
          -- skip internal JDK classes in autocomplete
          completion = {
            filteredTypes = { "com.sun.*", "sun.*", "jdk.*", "java.awt.*", "org.graalvm.*", "io.micrometer.shaded.*" },
          },
          settings = {
            ["org.eclipse.jdt.core.compiler.problem.rawTypeReference"] = "ignore",
            ["org.eclipse.jdt.core.compiler.problem.uncheckedTypeOperation"] = "ignore",
          },
        },
      }

      return opts
    end,
  },
}

-- Spring Boot
local function modulith_verify()
  local root = vim.fs.root(0, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" })
    or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts" })
  if not root then
    return Snacks.notify.warn("Not in a Maven or Gradle project")
  end
  local function has(name)
    return vim.uv.fs_stat(vim.fs.joinpath(root, name)) ~= nil
  end
  local gradle = has("gradlew") or has("settings.gradle") or has("settings.gradle.kts")
    or has("build.gradle") or has("build.gradle.kts")

  local files = vim.fn.systemlist({
    "rg", "-l", "--glob", "**/src/test/**/*.{java,kt}", "ApplicationModules", root,
  })
  if vim.v.shell_error ~= 0 or #files == 0 then
    return Snacks.notify.warn("No Modulith test found (a test using ApplicationModules)")
  end

  local cmd
  if gradle then
    cmd = { has("gradlew") and "./gradlew" or "gradle" }
    for _, file in ipairs(files) do
      local module = file:sub(#root + 2):match("^(.-)/?src/test/") or ""
      local task = module == "" and "test" or (":" .. module:gsub("/", ":") .. ":test")
      vim.list_extend(cmd, { task, "--tests", vim.fn.fnamemodify(file, ":t:r") })
    end
  else
    local classes = vim.tbl_map(function(f) return vim.fn.fnamemodify(f, ":t:r") end, files)
    cmd = { has("mvnw") and "./mvnw" or "mvn", "-q", "test", "-Dtest=" .. table.concat(classes, ","),
      "-Dsurefire.failIfNoSpecifiedTests=false" }
  end

  local opts = { cwd = root, interactive = false, win = { title = " Modulith verify " } }
  local previous = Snacks.terminal.get(cmd, vim.tbl_extend("force", opts, { create = false }))
  if previous then
    previous:close()
  end
  Snacks.terminal.open(cmd, opts)
end

local spring_boot = {
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {
      project_filter = function(root_dir)
        return require("spring_boot.util").has_spring_boot_dependency(root_dir)
      end,
    },
    keys = {
      { "<leader>j", "", desc = "+java" },
      { "<leader>jM", modulith_verify, desc = "Spring Modulith verify" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "vscode-spring-boot-tools" } },
  },
}

-- debug: load the project's .env, like <leader>jr does
local debug_env = {
  "mfussenegger/nvim-dap",
  optional = true,
  opts = function()
    require("java.tasks").debug_env()
  end,
}

return {
  jdtls,
  spring_boot,
  debug_env,
}
