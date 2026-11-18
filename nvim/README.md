# My Neovim

Built on LazyVim. LazyVim gives the base; these files change it.

## Where things are

| Want to change | Open |
|---|---|
| Settings (line numbers, tabs, ...) | `lua/config/options.lua` |
| Your own keys | `lua/config/keymaps.lua` |
| Things that run on events | `lua/config/autocmds.lua` |
| Theme, status line, start screen, icons, scrolling | `lua/plugins/look.lua` |
| File tree, find files, oil, harpoon | `lua/plugins/files.lua` |
| Git signs, blame, git log | `lua/plugins/git.lua` |
| Language servers, formatting, Python venv | `lua/plugins/code.lua` |
| Java and Spring Boot | `lua/plugins/java.lua` |
| Terminal, lazygit, window moves | `lua/plugins/terminal.lua` |
| Neovide only | `lua/plugins/neovide.lua` |

Helper code, used by the files above:

- `lua/java/` Java extras: lenses, icons, `<leader>j` tasks, class/test jump
- `lua/ui/` screen extras: file badge, harpoon bar, terminal panel, scrolling

Don't edit `lua/plugins/theme.lua`. Omarchy writes it when you switch themes.

## Lua you will see

A plugin:

```lua
{
  "owner/plugin-name",          -- GitHub repo
  opts = { some_setting = true }, -- its settings
  keys = {
    { "<leader>x", "<cmd>Something<cr>", desc = "What it does" },
  },
}
```

Turn a plugin off: `{ "owner/plugin-name", enabled = false }`

A key: `vim.keymap.set("n", "<leader>x", "<cmd>Something<cr>", { desc = "What it does" })`
(`"n"` = normal mode, `"i"` = insert, `"v"` = visual)

A setting: `vim.opt.relativenumber = true`

## Help

- `<leader>fk` search all keys
- `:Lazy` see plugins
- `:h <topic>` Neovim help
