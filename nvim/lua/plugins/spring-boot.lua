return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/spring-boot-tools/"
      local jar = vim.fn.glob(mason_path .. "language-server/spring-boot-language-server-*.jar")
      if jar ~= "" then
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "jproperties", "yaml" },
          callback = function(args)
            local root = vim.fs.root(args.buf, { "pom.xml", "build.gradle", "build.gradle.kts" })
            if not root then return end
            vim.lsp.start({
              name = "spring-boot",
              cmd = { "java", "-jar", jar },
              root_dir = root,
              filetypes = { "jproperties", "yaml" },
            })
          end,
        })
      end
      return opts
    end,
  },
}
