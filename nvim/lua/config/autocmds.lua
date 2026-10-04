vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.b.autoformat = false
  end,
})
