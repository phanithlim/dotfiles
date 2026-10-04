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
