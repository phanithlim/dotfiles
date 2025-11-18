return {
    {
        "nvim-telescope/telescope-file-browser.nvim",
        keys = {
            {
                "<leader>fb",
                function()
                    require("lazy").load({ plugins = { "telescope.nvim" } })
                    require("telescope").load_extension("file_browser")
                    require("telescope").extensions.file_browser.file_browser()
                end,
                desc = "Browse Files",
            },
        },
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
        },
    },

    {
        "nvim-telescope/telescope.nvim",
        optional = true,
        opts = function(_, opts)
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                },
            })
        end,
    },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = (build_cmd ~= "cmake") and "make"
            or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = build_cmd ~= nil,
        config = function(plugin)
            LazyVim.on_load("telescope.nvim", function()
                local ok, err = pcall(require("telescope").load_extension, "fzf")
                if not ok then
                    local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
                    if not vim.uv.fs_stat(lib) then
                        LazyVim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                        require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                            LazyVim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                        end)
                    else
                        LazyVim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
                    end
                end
            end)
        end,
    },

    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },

    {
        "stevearc/dressing.nvim",
        lazy = true,
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },
}
