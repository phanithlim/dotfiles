-- :FormatProject formats every file in the project, using the same formatter as <leader>cf
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { id = "format_project", title = "Format project" })
end

-- load a file without starting LSP or other plugins
local function quiet(fn)
  local saved = vim.o.eventignore
  vim.o.eventignore = "all"
  local ok, result = pcall(fn)
  vim.o.eventignore = saved
  if not ok then
    error(result)
  end
  return result
end

-- formatter names for a buffer, only the installed ones
local function formatters(list, buf)
  local conform = require("conform")
  if type(list) == "function" then
    list = list(buf)
  end
  local names = {}
  for _, name in ipairs(list or {}) do
    if type(name) == "string" and conform.get_formatter_info(name, buf).available then
      names[#names + 1] = name
      if list.stop_after_first then
        break
      end
    end
  end
  return names
end

-- project files that have a formatter
local function find_files(root, only_ft)
  local by_ft = require("conform").formatters_by_ft
  local out = vim.system({ "rg", "--files" }, { cwd = root, text = true }):wait().stdout or ""
  local files = {}
  for _, rel in ipairs(vim.split(out, "\n", { trimempty = true })) do
    local ft = vim.filetype.match({ filename = rel })
    if ft and by_ft[ft] and (not only_ft or ft == only_ft) then
      files[#files + 1] = { path = root .. "/" .. rel, list = by_ft[ft] }
    end
  end
  return files
end

local function run(files)
  local changed, failed, skipped = 0, {}, 0

  local function step(i)
    local file = files[i]
    if not file then
      local msg = ("Formatted %d of %d files"):format(changed, #files)
      if skipped > 0 then
        msg = msg .. ("\nSkipped %d open files with unsaved changes"):format(skipped)
      end
      if #failed > 0 then
        msg = msg .. "\nFailed:\n" .. table.concat(failed, "\n")
      end
      return notify(msg, #failed > 0 and vim.log.levels.WARN or nil)
    end
    if i % 10 == 0 then
      notify(("Formatting %d / %d"):format(i, #files))
    end

    local buf = vim.fn.bufadd(file.path)
    local was_loaded = vim.api.nvim_buf_is_loaded(buf)
    local function next_file()
      if not was_loaded then
        quiet(function() vim.api.nvim_buf_delete(buf, { force = true }) end)
      end
      vim.schedule(function() step(i + 1) end)
    end

    if was_loaded and vim.bo[buf].modified then
      skipped = skipped + 1
      return next_file()
    end
    quiet(function() vim.fn.bufload(buf) end)
    local names = formatters(file.list, buf)
    if #names == 0 then
      return next_file()
    end

    require("conform").format({ bufnr = buf, formatters = names, async = true, quiet = true }, function(err)
      if err then
        failed[#failed + 1] = vim.fn.fnamemodify(file.path, ":~:.")
      elseif vim.bo[buf].modified then
        vim.api.nvim_buf_call(buf, function() vim.cmd("silent noautocmd write") end)
        changed = changed + 1
      end
      next_file()
    end)
  end

  step(1)
end

function M.format(only_ft)
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local files = find_files(root, only_ft)
  if #files == 0 then
    return notify("No files to format", vim.log.levels.WARN)
  end
  local prompt = ("Format %d files in %s? (commit first to undo)"):format(#files, vim.fn.fnamemodify(root, ":t"))
  vim.ui.select({ "Yes", "No" }, { prompt = prompt }, function(choice)
    if choice == "Yes" then
      run(files)
    end
  end)
end

vim.api.nvim_create_user_command("FormatProject", function(args)
  M.format(args.args ~= "" and args.args or nil)
end, {
  nargs = "?",
  desc = "Format every file in the project",
  complete = function()
    return vim.tbl_keys(require("conform").formatters_by_ft)
  end,
})

return M
