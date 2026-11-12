vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    vim.b.autoformat = false
    -- treesitter indent is nesting depth * shiftwidth, so it must match the file's indentation
    -- (2 = Google Java Format, 4 = not yet reformatted Eclipse/IntelliJ style)
    local width = require("config.java_style").indent(args.buf)
    vim.bo[args.buf].shiftwidth = width
    vim.bo[args.buf].tabstop = width
    vim.bo[args.buf].softtabstop = width
  end,
})

require("config.notes")
