return {
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

      table.insert(opts.cmd, "--jvm-arg=-Xmx4g")

      local function jdk(version)
        return vim.fn.glob(vim.fn.expand("~/.sdkman/candidates/java/") .. version .. ".*", false, true)[1]
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
              java = { home = jdk("21") },
              annotationProcessing = { enabled = false },
            },
          },
          configuration = {
            updateBuildConfiguration = "automatic",
            runtimes = runtimes,
          },
          inlayHints = {
            parameterNames = { enabled = "all" },
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
