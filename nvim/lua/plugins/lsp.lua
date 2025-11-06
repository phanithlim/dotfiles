return {
    -- tools
    {
        "mason-org/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "luacheck",
                "shellcheck",
                "shfmt",
                "tailwindcss-language-server",
                "typescript-language-server",
                "css-lsp",
                "goimports",
                "gofumpt",
                "gomodifytags",
                "impl",
                "golangci-lint",
                "delve",
            })
        end,
    },
    -- lsp servers
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = true },
            servers = {
                cssls = {},
                tailwindcss = {
                    root_dir = function(...)
                        return require("lspconfig.util").root_pattern(".git")(...)
                    end,
                },
                tsserver = {
                    root_dir = function(...)
                        return require("lspconfig.util").root_pattern(".git")(...)
                    end,
                    single_file_support = false,
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "literal",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = false,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },
                html = {},
                lua_ls = {
                    -- enabled = false,
                    single_file_support = true,
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            completion = {
                                workspaceWord = true,
                                callSnippet = "Both",
                            },
                            misc = {
                                parameters = {
                                    -- "--log-level=trace",
                                },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            type = {
                                castNumberToInteger = true,
                            },
                            diagnostics = {
                                disable = { "incomplete-signature-doc", "trailing-space" },
                                -- enable = false,
                                groupSeverity = {
                                    strong = "Warning",
                                    strict = "Warning",
                                },
                                groupFileStatus = {
                                    ["ambiguity"] = "Opened",
                                    ["await"] = "Opened",
                                    ["codestyle"] = "None",
                                    ["duplicate"] = "Opened",
                                    ["global"] = "Opened",
                                    ["luadoc"] = "Opened",
                                    ["redefined"] = "Opened",
                                    ["strict"] = "Opened",
                                    ["strong"] = "Opened",
                                    ["type-check"] = "Opened",
                                    ["unbalanced"] = "Opened",
                                    ["unused"] = "Opened",
                                },
                                unusedLocalExclude = { "_*" },
                            },
                            format = {
                                enable = false,
                                defaultConfig = {
                                    indent_style = "space",
                                    indent_size = "2",
                                    continuation_indent_size = "2",
                                },
                            },
                        },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,
                            codelenses = {
                                gc_details = false,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = false,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = false,
                                rangeVariableTypes = true,
                            },
                            analyses = {
                                nilness = true,
                                unusedparams = true,
                                unusedwrite = true,
                                useany = true,
                                ST1000 = false,
                            },
                            usePlaceholders = true,
                            completeUnimported = true,
                            staticcheck = true,
                            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                            semanticTokens = true,
                        },
                    },
                },
                markdown = {},
                ruff = {
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
                ruff_lsp = {
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
            },
            setup = {},
        },
    },
    {
        "nvim-cmp",
        dependencies = { "hrsh7th/cmp-emoji" },
        opts = function(_, opts)
            table.insert(opts.sources, { name = "emoji" })
        end,
    },
}
