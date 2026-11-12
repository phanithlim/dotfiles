# Keys

One idea everywhere: **H/J/K/L moves, Shift moves the thing instead of the focus.**
Only my own keys are here. For everything else, ask the tool:

| Tool | Full list |
|---|---|
| Hyprland | `omarchy menu keybindings --print` |
| tmux | `prefix ?` |
| Neovim | `<leader>` and wait, or `<leader>sk` |
| Explorer | `?` |
| IntelliJ | read `ideavim/ideavimrc`, same keys as Neovim |

## Hyprland (Super)

| Keys | Action |
|---|---|
| `Super + H/J/K/L` | Focus window (+ Shift: swap) |
| `Super + 1…0` | Workspace on this monitor (+ Shift: send window) |
| `Super + M` | Move window laptop ⇄ external |
| `Super + Alt + L` | Layout dwindle ⇄ scrolling |
| `Super + - / =` | Narrower / wider (+ Shift: height) |
| `Super + Ctrl + /` | Cornix cheat sheet |
| `Super + N` | Neovide |
| `Alt + Shift` | English ⇄ Khmer |

## tmux (prefix `Ctrl-b`)

| Keys | Action |
|---|---|
| `Ctrl + H/J/K/L` | Move between panes and Neovim splits |
| `prefix \|` / `_` | Split side / down |
| `prefix f` | Project picker |
| `prefix g` | Lazygit |
| `prefix p` | Floating pane |
| `prefix Space` | Copy text with hints |

Neovide uses the same `Ctrl-b` keys, with tabs instead of tmux windows.

## Neovim (leader `Space`)

| Keys | Action |
|---|---|
| `<leader>a`, `Alt + 1…4` | Harpoon: add file, jump to file 1–4 |
| `Ctrl + /` | Terminal panel |
| `Ctrl + s` | Save without formatting |
| `<leader>-` | Oil |
| `<leader>j…` | Java: run, build, test, profiles |
| `<leader>t…` | Tests: file, nearest, last, debug |
| `gai` / `gao` | Who calls this / what it calls |
| `gsa` / `gsd` / `gsr` | Surround: add / delete / replace |
