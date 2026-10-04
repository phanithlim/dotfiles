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

return {
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
