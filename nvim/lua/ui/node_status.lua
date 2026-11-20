-- status line in JS/TS projects: Node, the framework and TypeScript, like " 22  󱄆 4.6  󰛦 6.0"
local M = {}

local cache = {} -- project root -> { text, mismatch }

-- "4.6" from the installed package, or from package.json when node_modules is missing
local function version(root, deps, name)
  local file = root .. "/node_modules/" .. name .. "/package.json"
  local ok, pkg = pcall(vim.json.decode, vim.uv.fs_stat(file) and table.concat(vim.fn.readfile(file), "\n") or "")
  local v = ok and type(pkg) == "table" and pkg.version or deps[name]
  return v and v:match("(%d+%.%d+)")
end

local function node_version(root)
  local ok, result = pcall(function()
    return vim.system({ "node", "--version" }, { cwd = root, text = true }):wait(2000)
  end)
  return ok and result.code == 0 and result.stdout:match("v(%d+)") or nil
end

-- the Node major from .nvmrc or .node-version, if the project pins one
local function wanted_node(root)
  for _, name in ipairs({ ".nvmrc", ".node-version" }) do
    local file = root .. "/" .. name
    if vim.uv.fs_stat(file) then
      return (vim.fn.readfile(file, "", 1)[1] or ""):match("(%d+)")
    end
  end
end

local frameworks = {
  { "nuxt", "\u{f1106}" },
  { "next", "\u{e83e}" },
  { "@angular/core", "\u{e753}" },
  { "vue", "\u{f0844}" },
  { "react", "\u{e7ba}" },
}

local function info(root)
  if cache[root] == nil then
    local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
    pkg = ok and type(pkg) == "table" and pkg or {}
    local deps = vim.tbl_extend("force", pkg.devDependencies or {}, pkg.dependencies or {})

    local node = node_version(root)
    local want = wanted_node(root)
    local parts = { "\u{e718} " .. (node or "?") }
    for _, f in ipairs(frameworks) do
      local v = deps[f[1]] and version(root, deps, f[1])
      if v then
        table.insert(parts, f[2] .. " " .. v)
        break
      end
    end
    local ts = deps.typescript and version(root, deps, "typescript")
    if ts then
      table.insert(parts, "\u{f06e6} " .. ts)
    end
    cache[root] = { text = table.concat(parts, "  "), mismatch = want ~= nil and want ~= node }
  end
  return cache[root]
end

local function root()
  if vim.b.node_root == nil then
    vim.b.node_root = vim.bo.buftype == "" and vim.fs.root(0, "package.json") or false
  end
  return vim.b.node_root or nil
end

function M.show()
  return root() ~= nil
end

-- lualine also calls these outside JS projects (the colour at startup), so no project means nothing
function M.status()
  local dir = root()
  return dir and info(dir).text or ""
end

-- red when the Node in use is not the one .nvmrc / .node-version asks for
function M.mismatch()
  local dir = root()
  return dir ~= nil and info(dir).mismatch
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "package.json", ".nvmrc", ".node-version" },
    callback = function()
      cache = {}
    end,
  })
end

return M
