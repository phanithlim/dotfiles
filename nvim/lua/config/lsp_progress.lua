local M = {}

local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local tasks = {}
local latest
local timer

local function refresh()
  require("lualine").refresh()
end

local function tick()
  if next(tasks) == nil then
    timer:stop()
  end
  refresh()
end

local function start_timer()
  timer = timer or vim.uv.new_timer()
  if not timer:is_active() then
    timer:start(0, 120, vim.schedule_wrap(tick))
  end
end

local function on_progress(args)
  local client_id = args.data.client_id
  local value = args.data.params.value
  local key = client_id .. ":" .. tostring(args.data.params.token)

  if value.kind == "end" then
    tasks[key] = nil
  else
    local client = vim.lsp.get_client_by_id(client_id)
    local previous = tasks[key] or {}
    tasks[key] = {
      client_id = client_id,
      name = client and client.name or "lsp",
      percentage = value.percentage or previous.percentage,
    }
    latest = key
  end
  start_timer()
end

local function on_detach(args)
  for key, task in pairs(tasks) do
    if task.client_id == args.data.client_id then
      tasks[key] = nil
    end
  end
end

function M.active()
  return next(tasks) ~= nil
end

function M.status()
  local task = tasks[latest] or select(2, next(tasks))
  if not task then
    return ""
  end
  local frame = spinner[math.floor(vim.uv.hrtime() / 1e8) % #spinner + 1]
  local percent = task.percentage and (" " .. task.percentage .. "%%") or ""
  return frame .. " " .. task.name .. percent
end

function M.setup()
  local group = vim.api.nvim_create_augroup("lsp_progress_status", { clear = true })
  vim.api.nvim_create_autocmd("LspProgress", { group = group, callback = on_progress })
  vim.api.nvim_create_autocmd("LspDetach", { group = group, callback = on_detach })
end

return M
