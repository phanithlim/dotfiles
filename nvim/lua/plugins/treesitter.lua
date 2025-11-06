return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "javascript",
                "typescript",
                "css",
                "gitignore",
                "graphql",
                "http",
                "json",
                "scss",
                "sql",
                "vim",
                "lua",
                "python",
                "go",
                "gomod",
                "gosum",
                "gowork",
                "markdownlint-cli2",
                "markdown-toc",
                "ninja",
                "rst",
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
        },
    },
}
