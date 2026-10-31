local function project_outgoing_calls()
  local root = vim.fs.root(0, { "gradlew", "mvnw", "settings.gradle.kts", "pom.xml", ".git" }) or vim.fn.getcwd()
  local files = {}
  local function annotation_only(file, lnum)
    files[file] = files[file] or vim.fn.readfile(file)
    local line = files[file][lnum] or ""
    if not line:find("^%s*@") then
      return false
    end
    return vim.trim(line:gsub("@[%w_.]+%b()", ""):gsub("@[%w_.]+", "")) == ""
  end
  Snacks.picker.lsp_outgoing_calls({
    title = "Outgoing Calls (project)",
    transform = function(item)
      if not item.file or item.file:find("^%a+://") or item.file:find(root .. "/", 1, true) ~= 1 then
        return false
      end
      if item.pos and annotation_only(item.file, item.pos[1]) then
        return false
      end
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },

      servers = {
        ["*"] = {
          keys = {
            { "gao", project_outgoing_calls, desc = "C[a]lls Outgoing (project)", has = "callHierarchy/outgoingCalls" },
            { "gaO", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing (all)", has = "callHierarchy/outgoingCalls" },
          },
        },

        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = "--exclude=SC2034",
            },
          },
        },

        kotlin_language_server = {
          cmd_env = {
            JAVA_HOME = vim.fn.glob(vim.fn.expand("~/.sdkman/candidates/java/") .. "21.*", false, true)[1],
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
