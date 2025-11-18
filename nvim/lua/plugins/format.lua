return {
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                go = { "goimports", "gofumpt" },
                json = { "prettier" },
                jsonc = { "prettier" },
            },
            formatters = {
                prettier = {
                    prepend_args = {
                        "--trailing-comma",
                        "none",
                    },
                },
            },
        },
    },
}
