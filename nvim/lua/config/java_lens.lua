-- Lenses above Java classes and methods, like IntelliJ:
--   2 implementations | 7 references | 󰀓 Dara Kim +1
-- References and implementations come from jdtls, queries and web config from the Spring Boot
-- server. A class or method with 0 references is greyed out.
local M = {}

-- servers put a lens at the method name; it is moved to the start of the line for display.
-- jdtls finds the references from the lens position, so it gets back the column it sent.
local name_col = setmetatable({}, { __mode = "k" })

local unused_ns = vim.api.nvim_create_namespace("java_unused")

-- Annotated ones (@GetMapping, @Bean, @Test, @Override, ...) are called by Spring, JUnit or
-- through an interface, so they are not greyed out.
local function mark_unused(buf, lens, col)
  local title = lens.command and lens.command.title or ""
  if not title:find("^0 references") then
    return
  end
  local row = lens.range.start.line
  local lines = vim.api.nvim_buf_get_lines(buf, math.max(row - 1, 0), row + 1, false)
  local line, above = lines[#lines] or "", row > 0 and lines[1] or ""
  local name = line:match("^[%w_$]+", col + 1)
  if not name or name == "main" or line:sub(1, col):find("@") or above:find("^%s*@") or above:find("%)%s*$") then
    return
  end
  vim.api.nvim_buf_set_extmark(buf, unused_ns, row, col, {
    end_col = col + #name,
    hl_group = "DiagnosticUnnecessary",
    priority = 150, -- above the semantic token colours
  })
end

-- git blame of the buffer text: blame[buf] = { tick = changedtick, authors = { [line] = name } }
local blame = {}
local missed = {} -- buffers with a references lens shown before their blame was ready

local function update_blame(buf, client_id)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local cached = blame[buf]
  if cached and (cached.tick == tick or cached.running == tick) then
    return
  end
  blame[buf] = { tick = cached and cached.tick, authors = cached and cached.authors or {}, running = tick }
  local file = vim.api.nvim_buf_get_name(buf)
  local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  vim.system(
    { "git", "blame", "--line-porcelain", "--contents", "-", "--", vim.fs.basename(file) },
    { cwd = vim.fs.dirname(file), stdin = text },
    vim.schedule_wrap(function(out)
      if not vim.api.nvim_buf_is_valid(buf) or blame[buf].running ~= tick then
        return
      end
      local authors = {}
      -- each line's header has "author <name>"; the code lines start with a tab
      for name in out.stdout:gmatch("\nauthor ([^\n]*)") do
        authors[#authors + 1] = name
      end
      blame[buf] = { tick = tick, authors = out.code == 0 and authors or {} }
      if missed[buf] and out.code == 0 then
        missed[buf] = nil
        vim.lsp.codelens.on_refresh(nil, nil, { client_id = client_id })
      end
    end)
  )
end

local decl = {
  class_declaration = true,
  interface_declaration = true,
  enum_declaration = true,
  record_declaration = true,
  annotation_type_declaration = true,
  method_declaration = true,
  constructor_declaration = true,
}

-- the class or method declared at row/col
local function declaration(buf, row, col)
  local parser = vim.treesitter.get_parser(buf, "java", { error = false })
  if not parser then
    return nil
  end
  parser:parse()
  local node = parser:named_node_for_range({ row, col, row, col })
  while node and not decl[node:type()] do
    node = node:parent()
  end
  return node
end

-- only interfaces, abstract classes and their methods can have implementations
local function can_implement(buf, node)
  if not node then
    return false
  end
  local parent = node:parent() and node:parent():parent()
  if node:type() == "interface_declaration" or (parent and parent:type() == "interface_declaration") then
    return true
  end
  local modifiers = node:child(0)
  return modifiers ~= nil and modifiers:type() == "modifiers"
    and vim.treesitter.get_node_text(modifiers, buf):find("%f[%w]abstract%f[^%w]") ~= nil
end

-- "Dara Kim +1": who wrote most lines of the class or method, and how many others changed it
local function author(buf, node)
  local authors = blame[buf] and blame[buf].authors or {}
  local first, _, last = node:range()
  local count, names = {}, {}
  for line = first + 1, last + 1 do
    local name = authors[line]
    if name then
      if name == "Not Committed Yet" or name:find("^External file") then
        name = "you"
      end
      if not count[name] then
        names[#names + 1] = name
      end
      count[name] = (count[name] or 0) + 1
    end
  end
  if #names == 0 then
    return nil
  end
  table.sort(names, function(a, b) return count[a] > count[b] end)
  return names[1] .. (#names > 1 and (" +" .. (#names - 1)) or "")
end

-- an extra lens after the counts; it sorts last because its column is one more
local function author_lens(buf, row, indent, node)
  local cached = blame[buf]
  if not cached or cached.tick ~= vim.api.nvim_buf_get_changedtick(buf) then
    missed[buf] = true
  end
  local name = node and author(buf, node)
  if name then
    local pos = { line = row, character = indent + 1 }
    return { range = { start = pos, ["end"] = pos }, command = { title = "\u{f0013} " .. name, command = "java_lens.blame" } }
  end
end

-- drop the lenses Lombok members get on their annotation (@Builder, @Getter, ...) and
-- "0 implementations" on types nothing can implement; add the author lens
local function filter(buf, lenses)
  local kept = {}
  for _, lens in ipairs(lenses) do
    local row, col = lens.range.start.line, lens.range.start.character
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    local kind = type(lens.data) == "table" and lens.data[3]
    local node = kind and declaration(buf, row, col)
    if not line:find("^%s*@") and (kind ~= "implementations" or can_implement(buf, node)) then
      kept[#kept + 1] = lens
      if kind == "references" then
        kept[#kept + 1] = author_lens(buf, row, #line:match("^%s*"), node)
      end
    end
  end
  return kept
end

local function wrap_requests(client)
  local request = client.request
  client.request = function(self, method, params, handler, bufnr)
    if method == "codeLens/resolve" and name_col[params] then
      local col = name_col[params]
      params = vim.deepcopy(params)
      params.range.start.character = col
    end
    if handler and (method == "textDocument/codeLens" or method == "codeLens/resolve") then
      local on_result = handler
      handler = function(err, result, ctx, ...)
        local buf = ctx and ctx.bufnr or bufnr or 0
        if method == "textDocument/codeLens" and not err then
          vim.api.nvim_buf_clear_namespace(buf, unused_ns, 0, -1)
          update_blame(buf, client.id)
          result = filter(buf, result or {})
        end
        for _, lens in ipairs(method == "codeLens/resolve" and { result } or result or {}) do
          if not (lens.command and lens.command.command == "java_lens.blame") then
            local row = lens.range.start.line
            local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
            name_col[lens] = lens.range.start.character
            lens.range.start.character = #line:match("^%s*")
            mark_unused(buf, lens, name_col[lens])
          end
        end
        return on_result(err, result, ctx, ...)
      end
    end
    return request(self, method, params, handler, bufnr)
  end
end

-- <leader>cc on a lens: show its locations in the picker, like gr
local function show_locations(client, title)
  return function(cmd)
    local items = vim.lsp.util.locations_to_items(cmd.arguments[3] or {}, client.offset_encoding)
    vim.fn.setqflist({}, " ", { title = title, items = items })
    Snacks.picker.qflist({ title = title })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("java_lens", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not (client and (client.name == "jdtls" or client.name == "spring-boot")) then
        return
      end
      if not client.java_lens then
        client.java_lens = true
        wrap_requests(client)
        client.commands["java.show.references"] = show_locations(client, "References")
        client.commands["java.show.implementations"] = show_locations(client, "Implementations")
        client.commands["java_lens.blame"] = function()
          require("gitsigns").blame_line({ full = true })
        end
      end
      vim.lsp.codelens.enable(true, { bufnr = args.buf })
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = "java_lens",
    callback = function(args)
      blame[args.buf], missed[args.buf] = nil, nil
    end,
  })
end

return M
