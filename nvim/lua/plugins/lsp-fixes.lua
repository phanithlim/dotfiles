return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts = opts or {}
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "jdtls" then
          client.handlers["workspace/configuration"] = function(err, result, ctx, config)
            if err then
              return vim.NIL
            end
            return vim.lsp.handlers["workspace/configuration"](err, result, ctx, config)
          end
        end
      end,
    })
    return opts
  end,
}
