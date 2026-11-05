vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.b.autoformat = false
    local width = require("config.java_style").indent(args.buf)
    vim.bo[args.buf].shiftwidth = width
    vim.bo[args.buf].tabstop = width
    vim.bo[args.buf].softtabstop = width
  end,
})

require("config.notes")
