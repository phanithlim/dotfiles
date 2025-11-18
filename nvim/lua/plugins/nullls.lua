return {
    {
        "nvimtools/none-ls.nvim",
        event = "LazyFile",
        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = { ensure_installed = { "gomodifytags", "impl" } },
            },
        },
        opts = function(_, opts)
            local nls = require("null-ls")
            opts.root_dir = opts.root_dir
                or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
            opts.sources = vim.list_extend(opts.sources or {}, {
                nls.builtins.formatting.fish_indent,
                nls.builtins.diagnostics.fish,
                nls.builtins.formatting.stylua,
                nls.builtins.formatting.shfmt,
                nls.builtins.code_actions.gomodifytags,
                nls.builtins.code_actions.impl,
                nls.builtins.formatting.goimports,
                nls.builtins.formatting.gofumpt,
            })
        end,
    },
}
