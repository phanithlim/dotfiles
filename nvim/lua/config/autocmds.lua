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

require("notes")
