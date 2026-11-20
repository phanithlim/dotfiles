-- an empty .java file starts with its package line and a class named after the file
local M = {}

local function fill(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines > 1 or lines[1] ~= "" then
    return
  end

  local path = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(path, ":t:r")
  if name == "module-info" then
    return
  end
  local dir = path:match("/src/[%w-]+/java/(.+)/[^/]+$")
  local package = dir and dir:gsub("/", ".")

  local text = {}
  if package then
    table.insert(text, "package " .. package .. ";")
  end
  if name ~= "package-info" then
    if package then
      table.insert(text, "")
    end
    vim.list_extend(text, { "public class " .. name .. " {", "  ", "}" })
  end
  if #text == 0 then
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
  if name ~= "package-info" and vim.api.nvim_get_current_buf() == buf then
    vim.api.nvim_win_set_cursor(0, { #text - 1, 2 })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("java_template", { clear = true }),
    pattern = "*.java",
    callback = function(args)
      fill(args.buf)
    end,
  })
end

return M
