return {
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                go = { "goimports", "gofumpt" },
                json = { "prettier" },
                jsonc = { "prettier" },
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
            },
            formatters = {
                injected = { options = { ignore_errors = true } },
            },
            biome = function(_, opts)
                opts.formatters_by_ft = opts.formatters_by_ft or {}
                for _, ft in ipairs(supported) do
                    opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
                    table.insert(opts.formatters_by_ft[ft], "biome")
                end

                opts.formatters = opts.formatters or {}
                opts.formatters.biome = {
                    require_cwd = true,
                }
            end,
        },
    },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        opts = {},
    },
    {
        "mfussenegger/nvim-lint",
        event = "LazyFile",
        opts = {
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },
            linters_by_ft = {
                fish = { "fish" },
            },
            ---@type table<string,table>
            linters = {},
        },
    },
}
