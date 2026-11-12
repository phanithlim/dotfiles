-- Java file icons for the explorer, incline and oil: the Spring role (controller, service, ...)
-- in the rich icon themes, else the type letter (C/I/E/R/@).
local M = {}

local cache = {}

local type_icons = {
  class = { "C", "SnacksPickerJavaClass" },
  interface = { "I", "SnacksPickerJavaInterface" },
  enum = { "E", "SnacksPickerJavaEnum" },
  record = { "R", "SnacksPickerJavaRecord" },
  annotation = { "@", "SnacksPickerJavaAnnotation" },
}

local role_icons = {
  app = { "󰌪", "MiniIconsGreen" },
  test = { "󰗡", "MiniIconsYellow" },
  advice = { "󰦻", "MiniIconsRed" },
  controller = { "󰖟", "MiniIconsAzure" },
  repository = { "󰓱", "MiniIconsYellow" },
  entity = { "󰆧", "MiniIconsPurple" },
  config = { "󰒓", "MiniIconsCyan" },
  service = { "󱁤", "MiniIconsBlue" },
  component = { "󰩦", "MiniIconsPurple" },
  exception = { "󰀨", "MiniIconsRed" },
  mapper = { "󰯍", "MiniIconsCyan" },
  dto = { "󰇰", "MiniIconsCyan" },
  request = { "󱋵", "MiniIconsCyan" },
  response = { "󱜾", "MiniIconsCyan" },
}

-- first match wins
local role_annotations = {
  { "app", "SpringBootApplication" },
  { "test", "Test", "SpringBootTest", "WebMvcTest", "DataJpaTest", "ParameterizedTest" },
  { "advice", "RestControllerAdvice", "ControllerAdvice" },
  { "controller", "RestController", "Controller" },
  { "repository", "Repository" },
  { "entity", "Entity", "Document", "Embeddable", "MappedSuperclass" },
  { "config", "Configuration", "ConfigurationProperties", "AutoConfiguration" },
  { "mapper", "Mapper" },
  { "service", "Service" },
  { "component", "Component" },
}
local role_suffixes = {
  { "exception", "Exception" },
  { "mapper", "Mapper" },
  { "dto", "Dto" },
  { "dto", "DTO" },
  { "request", "Request" },
  { "response", "Response" },
}

local function find_role(file, name, text)
  local used = {}
  for annotation in text:gmatch("@([%w_.]+)") do
    used[annotation:match("[%w_]+$")] = true
  end
  for _, entry in ipairs(role_annotations) do
    for i = 2, #entry do
      if used[entry[i]] then
        return entry[1]
      end
    end
  end
  if text:find("interface%s+" .. name .. "[^{]-extends[^{]-Repository%f[^%w_]") then
    return "repository"
  end
  for _, entry in ipairs(role_suffixes) do
    if #name > #entry[2] and name:sub(-#entry[2]) == entry[2] then
      return entry[1]
    end
  end
  if file:find("/src/test/", 1, true) and (name:match("Tests?$") or name:match("IT$")) then
    return "test"
  end
end

-- the kind is the first top-level type named like the file
local function find_kind(name, text)
  local best
  for _, kind in ipairs({ "class", "interface", "enum", "record" }) do
    local pos = text:find("%f[%w]" .. kind .. "%s+" .. name .. "%f[^%w_]")
    if pos and (not best or pos < best.pos) then
      local annotation = kind == "interface" and text:sub(pos - 1, pos - 1) == "@"
      best = { pos = pos, kind = annotation and "annotation" or kind }
    end
  end
  return best and best.kind
end

local function java_info(file)
  if not cache[file] then
    local name = vim.fn.fnamemodify(file, ":t:r")
    local ok, lines = pcall(vim.fn.readfile, file, "", 200)
    local text = table.concat(ok and lines or {}, "\n"):gsub("/%*.-%*/", ""):gsub("//[^\n]*", "")
    cache[file] = { kind = find_kind(name, text), role = find_role(file, name, text) }
  end
  return cache[file]
end

-- { glyph, hl } for a Java or Spring config file, nil for anything else
function M.icon(file)
  local theme = require("config.icon_themes").get()
  local base = vim.fn.fnamemodify(file, ":t")
  if base == "package-info.java" or base == "module-info.java" then
    return { theme.ascii and "P" or "󰏗", "MiniIconsPurple" }
  elseif base:match("%.java$") then
    local info = java_info(file)
    return theme.rich and role_icons[info.role] or type_icons[info.kind]
  elseif theme.rich and (base:match("^application.*%.ya?ml$") or base:match("^application.*%.properties$")
    or base:match("^bootstrap.*%.ya?ml$")) then
    return role_icons.app
  end
end

-- Picker format: snacks' file format, but Java files show as IntelliJ does,
-- "OrderService  com.example.shop.order · shop-api", with the role / type icon.
function M.format(item, picker)
  local ret = Snacks.picker.format.file(item, picker)
  local path = Snacks.picker.util.path(item)
  local icon = path and M.icon(path)
  if not icon then
    return ret
  end
  for i, seg in ipairs(ret) do
    if seg.resolve then -- the path segment; the icon is right before it
      ret[i - 1] = { Snacks.picker.util.align(icon[1], 2), icon[2], virtual = true }
      local rel = path:sub(#picker:cwd() + 2)
      local module, set, pkg, name = rel:match("^(.-)/?src/(%w+)/java/(.-)/?([^/]+)%.java$")
      if name then
        local where = {}
        for _, part in ipairs({ (pkg:gsub("/", ".")), module, set ~= "main" and set or "" }) do
          if part ~= "" then
            where[#where + 1] = part
          end
        end
        ret[i] = { name, "SnacksPickerFile", field = "file" }
        table.insert(ret, i + 1, { " " })
        table.insert(ret, i + 2, { table.concat(where, " · "), "SnacksPickerDir", field = "file" })
      end
      break
    end
  end
  return ret
end

-- Call after oil.setup(): oil's icon column only looks at the extension.
function M.patch_oil()
  local columns = require("oil.columns")
  local FIELD = require("oil.constants")
  local original = columns.get_column(nil, "icon")
  columns.register("icon", vim.tbl_extend("force", original, {
    render = function(entry, conf, bufnr)
      local dir = require("oil").get_current_dir(bufnr)
      local icon = dir and entry[FIELD.FIELD_TYPE] == "file" and M.icon(dir .. entry[FIELD.FIELD_NAME])
      if not icon then
        return original.render(entry, conf, bufnr)
      end
      local pad = (not conf or conf.add_padding ~= false) and " " or ""
      return { icon[1] .. pad, icon[2] }
    end,
  }))
end

local function set_hl()
  local function link(name, to) vim.api.nvim_set_hl(0, name, { link = to, default = true }) end
  link("SnacksPickerJavaClass", "Function")
  link("SnacksPickerJavaInterface", "String")
  link("SnacksPickerJavaEnum", "Keyword")
  link("SnacksPickerJavaRecord", "Type")
  link("SnacksPickerJavaAnnotation", "Special")
end
set_hl()

local group = vim.api.nvim_create_augroup("java_icons", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_hl })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.java",
  callback = function(args) cache[vim.fn.fnamemodify(args.file, ":p")] = nil end,
})

return M
