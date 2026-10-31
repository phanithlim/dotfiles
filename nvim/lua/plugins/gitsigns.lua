vim.api.nvim_create_autocmd("WinNew", {
  group = vim.api.nvim_create_augroup("gitsigns_popup_style", { clear = true }),
  callback = function()
    vim.schedule(function()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.w[w].gitsigns_preview and not vim.w[w].gitsigns_styled then
          vim.w[w].gitsigns_styled = true
          vim.wo[w].winhighlight = "NormalFloat:TermPanel,FloatBorder:TermPanelDim"
        end
      end
    end)
  end,
})

return {
  "lewis6991/gitsigns.nvim",
  opts = {
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 1,
      col = 0,
    },
  },
}
