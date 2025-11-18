return {
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
                enabled = false,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        enabled = true,
    },
    {
        "rcarriga/nvim-notify",
        opts = {
            on_open = function(win)
                local config = vim.api.nvim_win_get_config(win)
                config.border = "single"
                vim.api.nvim_win_set_config(win, config)
            end,
        },
    },
    {
        "nvimdev/dashboard-nvim",
        lazy = false,
        enabled = true,
        opts = function()
            local logo = [[



███╗   ███╗██╗     ██╗   ██╗███████╗██╗   ██╗██╗███╗   ███╗
████╗ ████║██║     ██║   ██║██╔════╝██║   ██║██║████╗ ████║
██╔████╔██║██║     ██║   ██║█████╗  ██║   ██║██║██╔████╔██║
██║╚██╔╝██║██║     ██║   ██║██╔══╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚═╝ ██║███████╗╚██████╔╝███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
            ]]

            logo = string.rep("\n", 8) .. logo .. "\n\n"

            local opts = {
                theme = "doom",
                hide = {
                    -- this is taken care of by lualine
                    -- enabling this messes up the actual laststatus setting after loading a file
                    statusline = false,
                },
                config = {
                    header = vim.split(logo, "\n"),
                    center = {
                        {
                            action = "lua LazyVim.pick()()",
                            desc = " Find File",
                            icon = " ",
                            key = "f",
                        },
                        {
                            action = "ene | startinsert",
                            desc = " New File",
                            icon = " ",
                            key = "n",
                        },
                        {
                            action = 'lua LazyVim.pick("oldfiles")()',
                            desc = " Recent Files",
                            icon = " ",
                            key = "r",
                        },
                        {
                            action = 'lua LazyVim.pick("live_grep")()',
                            desc = " Find Text",
                            icon = " ",
                            key = "g",
                        },
                        {
                            action = "lua LazyVim.pick.config_files()()",
                            desc = " Config",
                            icon = " ",
                            key = "c",
                        },
                        {
                            action = 'lua require("persistence").load()',
                            desc = " Restore Session",
                            icon = " ",
                            key = "s",
                        },
                        {
                            action = "LazyExtras",
                            desc = " Lazy Extras",
                            icon = " ",
                            key = "x",
                        },
                        {
                            action = "Lazy",
                            desc = " Lazy",
                            icon = "󰒲 ",
                            key = "l",
                        },
                        {
                            action = function()
                                vim.api.nvim_input("<cmd>qa<cr>")
                            end,
                            desc = " Quit",
                            icon = " ",
                            key = "q",
                        },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        return {
                            "⚡ Neovim loa ded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
                        }
                    end,
                },
            }

            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
                button.key_format = "  %s"
            end

            -- open dashboard after closing lazy
            if vim.o.filetype == "lazy" then
                vim.api.nvim_create_autocmd("WinClosed", {
                    pattern = tostring(vim.api.nvim_get_current_win()),
                    once = true,
                    callback = function()
                        vim.schedule(function()
                            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
                        end)
                    end,
                })
            end

            return opts
        end,
    },

    -- buffer line
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
        },
        opts = {
            options = {
                mode = "tabs",
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },

    -- filename
    {
        "b0o/incline.nvim",
        dependencies = {},
        event = "BufReadPre",
        priority = 1200,
        config = function()
            local helpers = require("incline.helpers")
            require("incline").setup({
                window = {
                    padding = 0,
                    margin = { horizontal = 0 },
                },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
                    local modified = vim.bo[props.buf].modified
                    local buffer = {
                        ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) }
                            or "",
                        " ",
                        { filename, gui = modified and "bold,italic" or "bold" },
                        " ",
                        guibg = "#363944",
                    }
                    return buffer
                end,
            })
        end,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- optional, but recommended
        },
        lazy = false, -- neo-tree will lazily load itself
    },

    {
        "nvim-mini/mini.icons",
        opts = {
            file = {
                [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
            },
            filetype = {
                gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
            },
        },
    },
    -- Markdown Preview
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
            checkbox = {
                enabled = false,
            },
        },
        ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
        config = function(_, opts)
            require("render-markdown").setup(opts)
            Snacks.toggle({
                name = "Render Markdown",
                get = require("render-markdown").get,
                set = require("render-markdown").set,
            }):map("<leader>um")
        end,
    },
    {
        "linux-cultist/venv-selector.nvim",
        cmd = "VenvSelect",
        opts = {
            options = {
                notify_user_on_venv_activation = true,
            },
        },
        ft = "python",
        keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
    },
    -- database UI
    {
        "tpope/vim-dadbod",
        cmd = "DB",
    },
    {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = "vim-dadbod",
        ft = sql_ft,
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = sql_ft,
                callback = function()
                    if LazyVim.has_extra("coding.nvim-cmp") then
                        local cmp = require("cmp")

                        -- global sources
                        ---@param source cmp.SourceConfig
                        local sources = vim.tbl_map(function(source)
                            return { name = source.name }
                        end, cmp.get_config().sources)

                        -- add vim-dadbod-completion source
                        table.insert(sources, { name = "vim-dadbod-completion" })

                        -- update sources for the current buffer
                        cmp.setup.buffer({ sources = sources })
                    end
                end,
            })
        end,
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        dependencies = "vim-dadbod",
        keys = {

            {
                "<leader>D",
                "<cmd>Neotree close<cr><cmd>tabnew<cr><bar><bar><cmd>DBUI<cr>",
                desc = "Toggle DBUI",
            },
        },
        init = function()
            local data_path = vim.fn.stdpath("data")

            vim.g.db_ui_auto_execute_table_helpers = 1
            vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
            vim.g.db_ui_show_database_icon = true
            vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
            vim.g.db_ui_use_nerd_fonts = true
            vim.g.db_ui_use_nvim_notify = true
            vim.g.db_ui_execute_on_save = false
        end,
    },
}
