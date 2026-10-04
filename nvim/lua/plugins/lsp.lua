return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },

      servers = {
        -- Bash
        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = "--exclude=SC2034",
            },
          },
        },

        -- TypeScript / JavaScript
        ts_ls = {
          settings = {
            typescript = {
              format = {
                placeOpenBraceOnNewLineForFunctions = false,
                placeOpenBraceOnNewLineForControlBlocks = false,
              },
            },
          },
        },

        -- Python: Ruff
        ruff = {
          init_options = {
            settings = {
              args = {},
            },
          },
        },

        -- Python: Pyright
        pyright = {
          settings = {
            pyright = {
              -- Ruff handles import organization
              disableOrganizeImports = true,
            },

            python = {
              analysis = {
                -- Enable auto-import suggestions
                autoImportCompletions = true,

                -- Type checking
                typeCheckingMode = "basic",

                -- Don't ignore the whole project
                ignore = {},
              },
            },
          },
        },
      },
    },
  },
}
