local function modulith_verify()
  local root = vim.fs.root(0, { "mvnw", "pom.xml" })
  if not root then
    return Snacks.notify.warn("Not in a Maven project")
  end
  local found = vim.fs.find(function(name, path)
    if not name:match("%.java$") then
      return false
    end
    local f = io.open(vim.fs.joinpath(path, name))
    local text = f and f:read("*a") or ""
    if f then
      f:close()
    end
    return text:find("ApplicationModules", 1, true) ~= nil
  end, { path = vim.fs.joinpath(root, "src/test"), limit = math.huge })
  if #found == 0 then
    return Snacks.notify.warn("No Modulith test found (a test using ApplicationModules)")
  end
  local classes = vim.tbl_map(function(f) return vim.fn.fnamemodify(f, ":t:r") end, found)
  local mvn = vim.uv.fs_stat(vim.fs.joinpath(root, "mvnw")) and "./mvnw" or "mvn"
  local cmd = { mvn, "-q", "test", "-Dtest=" .. table.concat(classes, ","), "-Dsurefire.failIfNoSpecifiedTests=false" }
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
