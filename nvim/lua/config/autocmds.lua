vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.b.autoformat = false
    -- indent must match the file: 2 or 4 spaces
    local width = require("java.style").indent(args.buf)
    vim.bo[args.buf].shiftwidth = width
    vim.bo[args.buf].tabstop = width
    vim.bo[args.buf].softtabstop = width
  end,
})

-- Java: on save, remove unused imports and sort them like google-java-format
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.java",
  callback = function(args)
    require("conform").format({ bufnr = args.buf, formatters = { "java_imports" }, timeout_ms = 3000, quiet = true })
  end,
})

-- keep a Java file's errors after closing it, so the file tree still shows them
vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end
    local ns = vim.lsp.diagnostic.get_namespace(client.id)
    local saved = vim.diagnostic.get(args.buf, { namespace = ns })
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) and #vim.diagnostic.get(args.buf, { namespace = ns }) == 0 then
        vim.diagnostic.set(ns, args.buf, saved)
      end
    end)
  end,
})

-- SQL: Enter runs the statement under the cursor, or the selection
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function(args)
    vim.keymap.set("n", "<CR>", function() require("db").run(false) end, { buffer = args.buf, desc = "Run statement" })
    vim.keymap.set("x", "<CR>", function() require("db").run(true) end, { buffer = args.buf, desc = "Run selection" })
    vim.keymap.set("n", "<leader>r", function() require("db").toggle_result() end, { buffer = args.buf, desc = "Show/hide result" })
  end,
})

-- indent lines: fainter levels, so the teal current-block line stands out; follows the theme
local function indent_colors()
  local bg = Snacks.util.color("Normal", "bg") or "#000000"
  local level = Snacks.util.color("NonText")
  if level then
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = Snacks.util.blend(level, bg, 0.5) })
  end
end
indent_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = indent_colors })

require("java.jdk").setup()
require("notes")
require("format_project")
