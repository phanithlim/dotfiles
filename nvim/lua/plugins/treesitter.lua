return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      local disable = opts.highlight.disable

      if type(disable) == "function" then
        local user_disable = disable
        opts.highlight.disable = function(lang, bufnr)
          if lang == "vim" or lang == "vimdoc" or lang == "query" then
            return true
          end
          return user_disable(lang, bufnr)
        end
        return
      end

      if type(disable) ~= "table" then
        disable = {}
      end

      local add = { "vim", "vimdoc", "query" }
      for _, lang in ipairs(add) do
        if not vim.tbl_contains(disable, lang) then
          table.insert(disable, lang)
        end
      end

      opts.highlight.disable = disable
    end,
  },
}
