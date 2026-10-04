return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },

      servers = {
        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = "--exclude=SC2034",
            },
          },
        },

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

        ruff = {
          init_options = {
            settings = {
              args = {},
            },
          },
        },

        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },

            python = {
              analysis = {
                autoImportCompletions = true,

                typeCheckingMode = "basic",

                ignore = {},
              },
            },
          },
        },
      },
    },
  },
}
