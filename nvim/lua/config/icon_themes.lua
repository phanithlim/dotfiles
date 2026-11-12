-- Icon themes, switched with :IconTheme or <leader>uo. All icons come from mini.icons
-- (LazyVim also points nvim-web-devicons at it), so a theme is mostly mini.icons opts.
local M = {}

local state_file = vim.fn.stdpath("data") .. "/icon_theme"

local function icon(glyph, color)
  return { glyph = glyph, hl = color == "Dim" and "IconThemeDim" or "MiniIcons" .. color }
end

-- Only folder glyphs as wide as the plain folder, or the tree looks misaligned.
-- The explorer uses the star folder for Spring modules and the lock folder for internal ones.
local folders = {}
local function folder(names, glyph, color)
  for _, name in ipairs(names) do
    folders[name] = icon(glyph, color)
  end
end
folder({ "src" }, "󰴉", "Purple")
folder({ "main" }, "󱂵", "Green")
folder({ "test", "tests", "integrationTest", "testFixtures" }, "󱥾", "Yellow")
folder({ "java" }, "󰉋", "Orange")
folder({ "kotlin" }, "󰉋", "Blue")
folder({ "resources" }, "󰲂", "Purple")
folder({ "static", "public", "assets", "images", "img" }, "󰉏", "Cyan")
folder({ "templates", "views" }, "󱉭", "Purple")
folder({ "i18n", "locale", "locales", "messages" }, "󰲃", "Cyan")
folder({ "config", "configs", "configuration", "conf", "properties" }, "󱁽", "Cyan")
folder({ "controller", "controllers", "web", "rest", "api", "endpoint", "resource" }, "󰡰", "Azure")
folder({ "service", "services", "usecase", "usecases", "application" }, "󱧺", "Blue")
folder({ "repository", "repositories", "repo", "dao", "persistence" }, "󱋣", "Yellow")
folder({ "entity", "entities", "model", "models", "domain" }, "󰉌", "Purple")
folder({ "dto", "dtos", "request", "response", "payload" }, "󰾶", "Cyan")
folder({ "mapper", "mappers", "converter", "converters" }, "󰾷", "Cyan")
folder({ "security", "auth" }, "󰢬", "Red")
folder({ "exception", "exceptions", "error", "errors" }, "󰉘", "Red")
folder({ "util", "utils", "helper", "helpers", "common", "shared", "support" }, "󱁾", "Grey")
folder({ "scheduler", "schedule", "job", "jobs", "batch", "task", "tasks" }, "󰝉", "Yellow")
folder({ "event", "events", "listener", "listeners", "messaging", "kafka" }, "󰉒", "Azure")
folder({ "client", "clients", "integration", "external", "gateway" }, "󰲁", "Blue")
folder({ "db", "migration", "migrations", "liquibase", "flyway", "changelog" }, "󱋤", "Yellow")
folder({ "docker", "k8s", "kubernetes", "helm", "charts" }, "󰞹", "Blue")
folder({ "scripts" }, "󱧻", "Green")
folder({ "lib", "libs" }, "󰛫", "Yellow")
folder({ "target", "build", "out", "dist", "bin", "logs", "node_modules", ".mvn", ".idea", ".settings", ".gradle" }, "󰉖", "Dim")

-- \u{} escapes: these glyphs got lost once when the file was edited
local gradle, maven = "\u{e7f2}", "\u{e82c}"
local files = {
  ["pom.xml"] = icon(maven, "Orange"),
  ["mvnw"] = icon(maven, "Grey"),
  ["mvnw.cmd"] = icon(maven, "Grey"),
  ["build.gradle"] = icon(gradle, "Cyan"),
  ["build.gradle.kts"] = icon(gradle, "Cyan"),
  ["settings.gradle"] = icon(gradle, "Cyan"),
  ["settings.gradle.kts"] = icon(gradle, "Cyan"),
  ["gradlew"] = icon(gradle, "Grey"),
  ["gradlew.bat"] = icon(gradle, "Grey"),
  [".sdkmanrc"] = icon("\u{f06ca}", "Orange"),
  ["lombok.config"] = icon("\u{f0493}", "Red"),
}

-- rich: folder icons stay when open, Java files show their Spring role, build folders are dimmed
local themes = {
  material = { desc = "Folder and Spring icons", mini = { directory = folders, file = files }, rich = true },
  mono = { desc = "Material in one color", mini = { directory = folders, file = files }, rich = true, mono = true },
  default = { desc = "LazyVim icons" },
  ascii = { desc = "No Nerd Font", mini = { style = "ascii" }, ascii = true },
}
local order = { "material", "mono", "default", "ascii" }

local current = (function()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  return ok and themes[lines[1]] and lines[1] or "material"
end)()

function M.get()
  return themes[current]
end

-- lazy.nvim caches resolved opts, so keep the base to rebuild from on a switch
local base_opts = {}
function M.extend(opts)
  base_opts = vim.deepcopy(opts or {})
  return vim.tbl_deep_extend("force", vim.deepcopy(base_opts), M.get().mini or {})
end

local mono_saved
local function set_hl()
  vim.api.nvim_set_hl(0, "IconThemeDim", { link = "Comment", default = true })
  local colors = { "Azure", "Blue", "Cyan", "Green", "Grey", "Orange", "Purple", "Red", "Yellow" }
  if M.get().mono then
    mono_saved = {}
    for _, c in ipairs(colors) do
      mono_saved[c] = vim.api.nvim_get_hl(0, { name = "MiniIcons" .. c })
      vim.api.nvim_set_hl(0, "MiniIcons" .. c, { link = "Directory" })
    end
  elseif mono_saved then
    for c, hl in pairs(mono_saved) do
      vim.api.nvim_set_hl(0, "MiniIcons" .. c, hl)
    end
    mono_saved = nil
  end
end

local function set(name)
  if not themes[name] then
    return Snacks.notify.error("Unknown icon theme: " .. name)
  end
  current = name
  vim.fn.writefile({ name }, state_file)
  if package.loaded["mini.icons"] then
    require("mini.icons").setup(M.extend(base_opts))
  end
  set_hl()
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    picker:find()
  end
  pcall(function() require("incline").refresh() end)
  vim.cmd.redrawstatus({ bang = true })
end

local function pick()
  vim.ui.select(order, {
    prompt = "Icon Theme",
    format_item = function(name)
      return (name == current and "● " or "  ") .. name .. " - " .. themes[name].desc
    end,
  }, function(name)
    if name then
      set(name)
    end
  end)
end

function M.setup()
  set_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("icon_theme", { clear = true }),
    callback = function()
      mono_saved = nil
      set_hl()
    end,
  })
  vim.api.nvim_create_user_command("IconTheme", function(args)
    if args.args == "" then pick() else set(args.args) end
  end, { nargs = "?", complete = function() return order end })
  vim.keymap.set("n", "<leader>uo", pick, { desc = "Icon Theme" })
end

return M
