local M = {}

-- Jump between a class and its test, like IntelliJ's Ctrl+Shift+T. Offers to create a missing test.
function M.alternate()
  local file = vim.api.nvim_buf_get_name(0)
  local root, set, rel = file:match("^(.*)/src/(%w+)/java/(.+)%.java$")
  if not root then
    return Snacks.notify.warn("Not a Java source file")
  end
  local dir, name = rel:match("^(.*)/") or "", rel:match("([^/]+)$")
  local function path(source_set, class)
    return ("%s/src/%s/java/%s%s.java"):format(root, source_set, dir ~= "" and dir .. "/" or "", class)
  end

  local targets = {}
  if set == "test" then
    targets = { path("main", name:match("^(.-)Tests?$") or name:match("^(.-)IT$") or name) }
  else
    for _, suffix in ipairs({ "Test", "Tests", "IT" }) do
      targets[#targets + 1] = path("test", name .. suffix)
    end
  end

  local found = vim.tbl_filter(function(f) return vim.uv.fs_stat(f) ~= nil end, targets)
  if #found == 1 then
    return vim.cmd.edit(found[1])
  elseif #found > 1 then
    return vim.ui.select(found, {
      prompt = "Open",
      format_item = function(f) return vim.fn.fnamemodify(f, ":t:r") end,
    }, function(f)
      if f then
        vim.cmd.edit(f)
      end
    end)
  elseif set == "test" then
    return Snacks.notify.warn("No class found for " .. name)
  end

  vim.ui.select({ "Create " .. name .. "Test" }, { prompt = "No test for " .. name }, function(choice)
    if choice then
      vim.fn.mkdir(vim.fn.fnamemodify(targets[1], ":h"), "p")
      vim.cmd.edit(targets[1])
      local lines = { "class " .. name .. "Test {", "}" }
      if dir ~= "" then
        lines = vim.list_extend({ "package " .. dir:gsub("/", ".") .. ";", "" }, lines)
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
  end)
end

-- "/x" from @GetMapping("/x"), @GetMapping(value = "/x"), @RequestMapping(path = {"/x", ...})
local function mapping_path(args)
  return args:match('value%s*=%s*{?%s*"([^"]*)"') or args:match('path%s*=%s*{?%s*"([^"]*)"')
    or args:match('^%s*{?%s*"([^"]*)"') or ""
end

local function join(prefix, path)
  local full = ("/" .. prefix .. "/" .. path):gsub("/+", "/")
  return #full > 1 and full:gsub("/$", "") or full
end

local function file_endpoints(file, items)
  local lines = vim.fn.readfile(file)
  local class_line = 1
  for i, line in ipairs(lines) do
    if line:find("%f[%w]class%s+%w+") then
      class_line = i
      break
    end
  end

  local prefix = ""
  for i, line in ipairs(lines) do
    local kind = line:match("^%s*@(%a*)Mapping%f[^%w]")
    if kind then
      -- an annotation can span lines
      local text, j = line, i
      while text:find("%(") and not text:find("%)") and j < i + 5 do
        j = j + 1
        text = text .. " " .. (lines[j] or "")
      end
      local path = mapping_path(text:match("%((.*)%)") or "")
      if i < class_line then
        prefix = path
      else
        local method = kind ~= "Request" and kind:upper() or text:match("RequestMethod%.(%u+)") or "ANY"
        local fn
        for k = j + 1, math.min(j + 10, #lines) do
          if not lines[k]:find("^%s*@") then
            fn = lines[k]:match("([%w_]+)%s*%(")
            if fn then
              break
            end
          end
        end
        local where = vim.fn.fnamemodify(file, ":t:r") .. "#" .. (fn or "?")
        items[#items + 1] = { method = method, path = path, where = where, file = file, pos = { i, 0 }, prefix = prefix }
      end
    end
  end
end

local method_hl = {
  GET = "MiniIconsGreen",
  POST = "MiniIconsYellow",
  PUT = "MiniIconsBlue",
  PATCH = "MiniIconsCyan",
  DELETE = "MiniIconsRed",
}

-- All Spring endpoints in the project, searchable by method, URL or controller
function M.endpoints()
  local root = LazyVim.root()
  local files = vim.fn.systemlist({ "rg", "-l", "--glob", "*.java", "--glob", "!**/src/test/**", "@(Rest)?Controller\\b", root })
  local items = {}
  for _, file in ipairs(vim.v.shell_error == 0 and files or {}) do
    file_endpoints(file, items)
  end
  for _, item in ipairs(items) do
    item.path = join(item.prefix, item.path)
    item.text = item.method .. " " .. item.path .. " " .. item.where
  end
  table.sort(items, function(a, b) return a.path == b.path and a.method < b.method or a.path < b.path end)
  if #items == 0 then
    return Snacks.notify.warn("No endpoints found")
  end

  Snacks.picker({
    title = "Endpoints",
    items = items,
    format = function(item)
      return {
        { ("%-6s"):format(item.method), method_hl[item.method] or "Comment" },
        { " " },
        { item.path },
        { "  " },
        { item.where, "SnacksPickerComment" },
      }
    end,
    preview = "file",
  })
end

return M
