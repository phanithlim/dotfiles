-- language servers
-- outgoing calls: only your own code, no JDK or Lombok
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

local lsp = {
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

        -- KLS's bundled Kotlin compiler can't parse Java 25 version strings, so pin it to JDK 21
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

-- language server fixes
local lsp_fixes = {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts = opts or {}
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "jdtls" then
          client.handlers["workspace/configuration"] = function(err, result, ctx, config)
            if err then
              return vim.NIL
            end
            return vim.lsp.handlers["workspace/configuration"](err, result, ctx, config)
          end
        end
      end,
    })
    return opts
  end,
}

-- JS/TS/Vue: Prettier only if the project uses it; ESLint-styled projects (like Nuxt) use ESLint
local function prettier_or_eslint(buf)
  if require("js_style").uses_eslint(buf) then
    return { "eslint_fix", lsp_format = "never" }
  end
  return { "prettier" }
end

-- formatting
local formatting = {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      vue = prettier_or_eslint,
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      javascript = prettier_or_eslint,
      javascriptreact = prettier_or_eslint,
      typescript = prettier_or_eslint,
      typescriptreact = prettier_or_eslint,
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      graphql = { "prettier" },
      xml = { "xmllint" },
      java = { "google-java-format" },
    },
    formatters = {
      -- run sqlfluff everywhere, postgres by default
      sqlfluff = {
        args = { "format", "--dialect=postgres", "-" },
        require_cwd = false,
        -- 1 = formatted, but some lint warnings remain
        exit_codes = { 0, 1 },
      },
      -- the project's own ESLint, like `pnpm lint --fix`
      eslint_fix = {
        command = "node",
        args = { vim.fn.stdpath("config") .. "/scripts/eslint-fix.mjs", "$FILENAME" },
        stdin = true,
        cwd = function(self, ctx) return require("conform.util").root_file(require("js_style").eslint_files)(self, ctx) end,
      },
      -- only remove unused imports and sort them, the way Spotless expects
      java_imports = {
        command = "google-java-format",
        args = { "--fix-imports-only", "-" },
        stdin = true,
      },
      xmllint = {
        command = "xmllint",
        args = { "--format", "-" },
        env = { XMLLINT_INDENT = "  " },
        stdin = true,
      },
    },
  },
}

-- syntax highlighting
local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "groovy" },
  },
}

-- markdown
local markdown = {
  -- Notes don't need style rules like line length.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = { enabled = true },
      -- Keep the cursor line rendered too, so lines don't shift as you move.
      anti_conceal = { enabled = false },
      win_options = {
        concealcursor = { rendered = "nc" },
      },
    },
  },
}

-- database panel with the project's databases
local database = {
  "kristijanhusak/vim-dadbod-ui",
  keys = {
    { "<leader>D", function() require("db").toggle() end, desc = "Database (project)" },
  },
}

-- big files
local bigfile = {
  "folke/snacks.nvim",
  opts = {
    bigfile = {
      size = 1.5 * 1024 * 1024,
      line_length = 100000,
    },
  },
}

-- outline, LaTeX and images
local code_tools = {
  {
    "stevearc/aerial.nvim",
    opts = {
      nerd_font = "auto",
      icons = {
        Array = "󰅪 ",
        Boolean = "󰨙 ",
        Class = "󰠱 ",
        Constant = "󰏿 ",
        Constructor = "󰒓 ",
        Enum = "󰕘 ",
        EnumMember = "󰕚 ",
        Event = "󱐋 ",
        Field = "󰜢 ",
        File = "󰈙 ",
        Function = "󰊕 ",
        Interface = "󰠱 ",
        Key = "󰌋 ",
        Method = "󰆧 ",
        Module = "󰏗 ",
        Namespace = "󰌗 ",
        Null = "󰟢 ",
        Number = "󰎠 ",
        Object = "󰅩 ",
        Operator = "󰆕 ",
        Package = "󰏖 ",
        Property = "󰖷 ",
        String = "󰀬 ",
        Struct = "󰙅 ",
        TypeParameter = "󰅲 ",
        Variable = "󰀫 ",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Code Outline" },
      { "{", "<cmd>AerialPrev<cr>", desc = "Prev Symbol" },
      { "}", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
    },
  },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_automatic = 1
    end,
  },
  {
    "3rd/image.nvim",
    build = false,
    ft = { "norg", "typst" },
    opts = {
      processor = "magick_cli",
    },
  },
}

-- Python venv, completion, tests
local extras = {
  -- gsa on a linewise selection puts the new tags on their own lines, indented
  {
    "nvim-mini/mini.surround",
    opts = { respect_selection_type = true },
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
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<A-d>"] = { "scroll_documentation_down", "fallback" },
        ["<A-u>"] = { "scroll_documentation_up", "fallback" },
      },
    },
  },
  -- test output popup closes at once, so use <leader>to instead
  {
    "nvim-neotest/neotest",
    opts = { output = { open_on_run = false } },
  },
  { "iamcco/markdown-preview.nvim", enabled = false },
}

return {
  lsp,
  lsp_fixes,
  formatting,
  treesitter,
  markdown,
  database,
  bigfile,
  code_tools,
  extras,
}
