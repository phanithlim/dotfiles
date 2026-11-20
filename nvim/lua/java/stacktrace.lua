-- copy a stack trace, press <leader>jx: list your own code's lines from it and jump there
local M = {}

-- "pkg/Name.java" -> full path, for every source file in the project
local function source_files(root)
  local out = vim.system({ "rg", "--files", "-g", "*.java", "-g", "*.kt" }, { cwd = root, text = true }):wait().stdout or ""
  local files = {}
  for _, rel in ipairs(vim.split(out, "\n", { trimempty = true })) do
    local key = rel:match("/java/(.+)$") or rel:match("/kotlin/(.+)$")
    if key then
      files[key] = files[key] or root .. "/" .. rel
    end
  end
  return files
end

function M.open()
  local text = vim.fn.getreg("+")
  if not text:find("%.java:%d") and not text:find("%.kt:%d") then
    text = vim.fn.getreg('"')
  end
  local root = vim.fs.root(0, { ".git", "gradlew", "mvnw", "pom.xml" }) or vim.fn.getcwd()
  local files = source_files(root)

  local items, error_line = {}, nil
  for _, line in ipairs(vim.split(text, "\n")) do
    -- the exception message: "Caused by: x.y.FooException: message"
    local message = line:match("^%s*Caused by: (.+)$") or line:match("^[%w_.$]+Exception: .+$") or line:match("^[%w_.$]+Error: .+$")
    if message then
      error_line = message
    end
    -- "at kh.gov.x.Foo$Inner.method(Foo.java:42)"
    local class, method, file, lnum = line:match("at ([%w_.$]+)%.([%w_$<>]+)%(([%w_$]+%.%a+):(%d+)%)")
    if class then
      local pkg = class:gsub("%$.*", ""):match("^(.*)%.") or ""
      local path = files[(pkg:gsub("%.", "/") .. "/" .. file):gsub("^/", "")]
      if path then
        items[#items + 1] = {
          filename = path,
          lnum = tonumber(lnum),
          text = method .. (error_line and ("  ← " .. error_line) or ""),
        }
      end
    end
  end

  if #items == 0 then
    return Snacks.notify.warn("No lines from this project in the copied text.\nCopy the stack trace first.")
  end
  vim.fn.setqflist({}, " ", { title = "Stack trace", items = items })
  Snacks.picker.qflist({ title = "Stack trace" })
end

return M
