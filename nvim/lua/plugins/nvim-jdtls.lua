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
        if jar ~= "" then table.insert(bundles, jar) end
      end

      local ok, spring_boot = pcall(require, "spring_boot")
      if ok then
        vim.list_extend(bundles, spring_boot.java_extensions())
      end

      opts.init_options = { bundles = bundles }

      table.insert(opts.cmd, "--jvm-arg=-Xmx4g")

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
          },
          configuration = {
            updateBuildConfiguration = "automatic",
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
