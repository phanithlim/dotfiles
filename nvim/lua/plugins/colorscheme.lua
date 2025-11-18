return {
    -- Default Theme
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },

    -- Colorscheme
    { "ellisonleao/gruvbox.nvim" },
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        opts = {
            lsp_styles = {
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = { "undercurl" },
                    information = { "undercurl" },
                },
            },
            flavour = "mocha",
            transparent_background = true,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
            integrations = {
                aerial = true,
                alpha = true,
                cmp = true,
                dashboard = true,
                flash = true,
                fzf = true,
                grug_far = true,
                gitsigns = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                leap = true,
                lsp_trouble = true,
                mason = true,
                mini = true,
                navic = { enabled = true, custom_bg = "lualine" },
                neotest = true,
                neotree = true,
                noice = true,
                notify = true,
                snacks = true,
                telescope = true,
                treesitter_context = true,
                which_key = true,
            },
            custom_highlights = function(colors)
                return {
                    FloatBorder = { fg = colors.lavender, bg = colors.mantle },
                    NormalFloat = { bg = colors.mantle },
                    -- WinSeparator = { fg = colors.surface1 },
                    -- Comment = { fg = colors.flamingo },
                    -- TabLineSel = { bg = colors.pink },
                    -- CmpBorder = { fg = colors.surface2 },
                    -- Directory = { fg = colors.red },
                    -- FolderIcon = { fg = colors.blue }, -- Pmenu = { bg = colors.none },
                }
            end,
        },
        specs = {
            {
                "akinsho/bufferline.nvim",
                optional = true,
                opts = function(_, opts)
                    if (vim.g.colors_name or ""):find("catppuccin") then
                        opts.highlights = require("catppuccin.special.bufferline").get_theme()
                    end
                end,
            },
        },
    },
}
