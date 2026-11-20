-- reload files changed outside Neovim (Claude, git), also while switching herdr panes,
-- which Neovim doesn't see as a focus change
local function checktime()
  if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("silent! checktime")
  end
end
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, { callback = checktime })
vim.fn.timer_start(3000, function() checktime() end, { ["repeat"] = -1 })

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

-- ESLint projects (like Nuxt): no format on save, ESLint is too slow;
-- <leader>cf runs it in the background, so Neovim never freezes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vue", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function(args)
    if require("js_style").uses_eslint(args.buf) then
      vim.b[args.buf].autoformat = false
      vim.keymap.set({ "n", "x" }, "<leader>cf", function()
        require("conform").format({ bufnr = args.buf, async = true })
      end, { buffer = args.buf, desc = "Format (ESLint)" })
    end
  end,
})

-- Java: on save, remove unused imports and sort them like google-java-format
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.java",
  callback = function(args)
    require("conform").format({ bufnr = args.buf, formatters = { "java_imports" }, timeout_ms = 3000, quiet = true })
  end,
})

-- no jdtls in popups (like <leader>ghb's code preview): they have no file name
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "jdtls" and vim.api.nvim_buf_get_name(args.buf) == "" then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) and vim.lsp.buf_is_attached(args.buf, client.id) then
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end)
    end
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
