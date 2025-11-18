return {
    -- Basic neotest dependency
    { "nvim-neotest/neotest-plenary" },

    -- 🧪 Neotest setup for Go
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neotest/neotest-plenary",
            "fredrikaverpil/neotest-golang",
            "mfussenegger/nvim-dap",
        },
        opts = function(_, opts)
            opts.adapters = {
                require("neotest-plenary"),
                require("neotest-golang")({
                    go_test_args = { "-v", "-count=1" },
                }),
            }
            return opts
        end,
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run()
                end,
                desc = "Run nearest test",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Run tests in file",
            },
            {
                "<leader>ta",
                function()
                    require("neotest").run.run(vim.fn.getcwd())
                end,
                desc = "Run all tests",
            },
            {
                "<leader>dt",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Debug nearest test (Go)",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Open test output",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Toggle test summary",
            },
        },
    },

    -- 🐞 Go-specific DAP adapter (uses Delve)

    {
        "leoluz/nvim-dap-go",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function(_, opts)
            local dap = require("dap")
            require("dap-go").setup(opts)

            -- 👇 Custom debug configuration for your cmd/api package
            dap.configurations.go = {
                {
                    type = "go",
                    name = "Debug API (cmd/api)",
                    request = "launch",
                    program = "${workspaceFolder}/cmd/api", -- ✅ run this directory
                    mode = "debug",
                },
                {
                    type = "go",
                    name = "Debug current file",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "go",
                    name = "Debug test (nearest)",
                    request = "launch",
                    mode = "test",
                    program = "${file}",
                },
            }
        end,
    },

    -- 🪄 DAP UI
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
            {
                "<leader>du",
                function()
                    require("dapui").toggle({})
                end,
                desc = "Toggle DAP UI",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                desc = "Evaluate expression",
                mode = { "n", "x" },
            },
        },
        opts = {},
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup(opts)
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({})
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close({})
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close({})
            end
        end,
    },

    -- 🧩 Core DAP setup
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            { "theHamsta/nvim-dap-virtual-text", opts = {} },
            {
                "mason-org/mason.nvim",
                opts = { ensure_installed = { "delve" } },
            },
            {
                "leoluz/nvim-dap-go",
                opts = {},
            },
        },
        keys = {
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Breakpoint condition",
            },
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle breakpoint",
            },
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "Run / Continue",
            },
            {
                "<leader>dC",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "Run to cursor",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step into",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_out()
                end,
                desc = "Step out",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_over()
                end,
                desc = "Step over",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Toggle REPL",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "Terminate",
            },
            {
                "<leader>dw",
                function()
                    require("dap.ui.widgets").hover()
                end,
                desc = "Widgets",
            },
        },
        config = function()
            local dap = require("dap")
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            -- Signs for breakpoints
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo" })
        end,
    },
}
