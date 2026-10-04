# Keybindings

[Hyprland](#hyprland) · [tmux](#tmux) · [Neovim](#neovim) · [Explorer](#explorer) · [Neovide](#neovide) · [Terminal](#terminal)

**[L2 + H]** = Cornix: hold layer 2, tap H. See [keyboard-cornix.md](keyboard-cornix.md).

## Hyprland

**Windows**

| Keys | Action |
|---|---|
| `Super + H/J/K/L` | Focus window **[L2 + H/J/K/L]** |
| `Super + Shift + H/J/K/L` | Swap window **[L2 + Shift + H/J/K/L]** |
| `Super + W` | Close **[L4 + W]** |
| `Super + T` | Float / tile **[L4]** |
| `Super + F` | Full screen **[L4]** |
| `Super + - / =` | Resize (add `Shift` for height) **[L3]** |
| `Super + S` | Scratchpad |

**Workspaces & monitors**

| Keys | Action |
|---|---|
| `Super + 1…0` | Workspace on this monitor **[L2 + top row]** |
| `Super + Shift + 1…0` | Move window to workspace **[L3 + top row]** |
| `Super + Tab` / `Super + Shift + Tab` | Next / previous occupied workspace **[L2 + left knob]** |
| `Super + M` | Move window laptop ⇄ external **[L2 + M]** |
| `Super + Ctrl + Shift + 1 / 2` | Send window to laptop / external |
| `Super + Ctrl + ← / →` | Focus monitor left / right |
| `Super + Shift + Alt + ← / →` | Move workspace to left / right monitor |
| `Super + Ctrl + G` | Grab stranded windows |

**Apps & menus**

| Keys | Action |
|---|---|
| `Super + Space` | Omarchy menu |
| `Super + Alt + Space` | Apps **[L4 + left Super thumb]** |
| `Super + Escape` | System menu |
| `Super + Enter` | Terminal **[L4 + Enter]** |
| `Super + Alt + Enter` | Terminal + tmux **[L4 + I]** |
| `Super + N` | Neovide **[L4 + U]** |
| `Super + Shift + Enter` | Browser **[L4 + L]** |
| `Super + Shift + F` | Files **[L4 + K]** |
| `Super + Shift + O` | Obsidian |
| `Super + Ctrl + L` | Lock **[L4 + G]** |
| `Super + Ctrl + V` | Clipboard **[L4 + C]** |
| `Super + Ctrl + E` | Emoji **[L4 + V]** |
| `Print` | Screenshot |
| `Alt + Shift` | English ⇄ Khmer |

Full list: `omarchy menu keybindings --print`

## tmux

Prefix `Ctrl-b` **[hold right Space + B]**

| Keys | Action |
|---|---|
| `Ctrl + H/J/K/L` | Move between panes and Neovim splits |
| `prefix c` | New window |
| `prefix Tab` | Last window |
| `prefix Ctrl-p` / `Ctrl-n` | Previous / next window **[combo A+B / S+B]** |
| `prefix \|` / `_` | Split side / down |
| `prefix H/J/K/L` | Resize pane |
| `prefix x` / `X` | Kill pane / window |
| `prefix f` | Project picker |
| `prefix S` | Switch session |
| `prefix g` | Lazygit |
| `prefix p` | Floating pane |
| `prefix Space` | Copy text with hints |
| `prefix r` | Reload |

## Neovim

Leader = `Space`. LazyVim defaults also apply.

| Keys | Action |
|---|---|
| `<leader>a` | Harpoon: add file |
| `Alt + 1…4` | Harpoon: file 1–4 **[L4 + A/S/D/F]** |
| `Ctrl + p` / `n` | Harpoon: previous / next **[L4 + left knob]** |
| `<leader>h1…h4` | Harpoon: put file in slot |
| `<leader>hh` | Harpoon: picker |
| `Ctrl + e` | Harpoon: menu |
| `Ctrl + /` | Floating terminal |
| `Ctrl + s` | Save without format |
| `Tab` / `Shift + Tab` | Next / previous buffer |
| `<leader>-` | Oil file browser |
| `<leader>o` | Code outline |
| `<leader>sj` | Jump list |
| `<leader>jM` | Spring Modulith verify: runs the `ApplicationModules` tests with Maven or Gradle |
| `<leader>jp` | Switch Maven profile |

## Explorer

`<leader>e` opens it. Hidden files are shown by default. `?` lists every key.

| Key | Action |
|---|---|
| `l` / `h` | Open / close folder |
| `Backspace` | Go up a folder |
| `a` | New file (end with `/` for a folder) |
| `r` | Rename |
| `d` | Delete |
| `c` / `m` | Copy / move |
| `y` / `p` | Yank / paste file |
| `Y` | Copy path (relative, absolute, name, folder) |
| `H` | Show / hide hidden files |
| `I` | Show / hide gitignored files |
| `F` | Find files in this folder |
| `<leader>/` | Grep in this folder |
| `O` | Open folder in Oil |
| `o` | Open with system app |
| `Ctrl + v` / `Ctrl + s` | Open in vertical / horizontal split |
| `Ctrl + t` | Terminal in this folder |
| `Ctrl + c` | Make this folder the working directory |
| `P` | Toggle preview |
| `Z` | Collapse all |
| `]g` / `[g` | Next / previous git change |
| `]d` / `[d` | Next / previous diagnostic |

## Neovide

Neovim keys, plus tmux keys on `Ctrl-b` (tabs = tmux windows).

| Keys | Action |
|---|---|
| `Ctrl-b c` | New tab |
| `Ctrl-b 1…9` | Go to tab |
| `Ctrl-b Ctrl-p` / `Ctrl-n` | Previous / next tab **[combo A+B / S+B]** |
| `Ctrl-b \|` / `_` | Split side / down |
| `Ctrl-b h/j/k/l` | Move between splits |
| `Ctrl-b x` / `X` | Close split / tab |
| `Ctrl-b g` | Lazygit |
| `Ctrl + = / - / 0` | Zoom |

## Terminal

| Keys | Action |
|---|---|
| `Ctrl + Insert` | Copy |
| `Shift + Insert` | Paste |
