# Keybindings

Everything I use day to day, grouped by tool. For the physical keys on the
Cornix LP (which layer sends what), see [keyboard-cornix.md](keyboard-cornix.md).

- [Hyprland (Omarchy)](#hyprland-omarchy)
- [tmux](#tmux)
- [Neovim](#neovim)
- [Neovide](#neovide)
- [Terminals: Ghostty and kitty](#terminals-ghostty-and-kitty)

The idea running through all of them: **H / J / K / L moves focus at every level**.

| Keys | Moves between |
|---|---|
| `Super + H/J/K/L` | Hyprland windows |
| `Ctrl + H/J/K/L` | Neovim splits and tmux panes (seamlessly, via vim-tmux-navigator) |
| `Ctrl-b` then `H/J/K/L` | tmux panes, and Neovim splits in Neovide |

---

## Hyprland (Omarchy)

Full live list: `omarchy menu keybindings --print`. Config: [`hypr/`](../hypr).

### My custom bindings

| Keys | Action | Defined in |
|---|---|---|
| `Super + H / J / K / L` | Focus window left / down / up / right (replaces Omarchy's defaults on J/K/L) | `bindings.lua` |
| `Super + Alt + L` | Toggle workspace layout | `bindings.lua` |
| `Super + N` | Neovide | `bindings.lua` |
| `Super + Shift + O` | Obsidian (software rendering + Wayland IME) | `bindings.lua` |
| `Super + 1 … 0` | Switch to workspace 1–10 **on this monitor** | `split-monitor-workspaces.lua` |
| `Super + Shift + 1 … 0` | Move window to workspace on this monitor | `split-monitor-workspaces.lua` |
| `Super + Shift + Alt + 1 … 0` | Move window silently | `split-monitor-workspaces.lua` |
| `Super + Tab` / `Super + Shift + Tab` | Next / previous **occupied** workspace (skips empty ones) | `split-monitor-workspaces.lua` |
| `Super + scroll` | Same, with the mouse wheel | `split-monitor-workspaces.lua` |
| `Super + Ctrl + 1 … 5` | Focus monitor 0–4 | `split-monitor-workspaces.lua` |
| `Super + Ctrl + Shift + 1 … 5` | Send window to monitor 0–4 | `split-monitor-workspaces.lua` |
| `Super + Ctrl + ← / →` | Focus monitor left / right | `split-monitor-workspaces.lua` |
| `Super + Ctrl + Shift + ← / →` | Send window to left / right monitor | `split-monitor-workspaces.lua` |
| `Super + Ctrl + G` | Grab windows stranded on a missing monitor | `split-monitor-workspaces.lua` |
| `Alt + Shift` | Switch keyboard layout English ⇄ Khmer | `input.lua` |

> **Known clash:** Omarchy also binds `Super + Ctrl + 1 … 9` to "Bar panel 1–9".
> Keys 1–5 now trigger both that and "Focus monitor".

### Omarchy defaults I use most

| Keys | Action |
|---|---|
| `Super + Space` | Omarchy menu |
| `Super + Alt + Space` | Apps menu |
| `Super + Escape` | System menu |
| `Super + Enter` | Terminal |
| `Super + Alt + Enter` | Terminal with tmux |
| `Super + Shift + Enter` | Browser |
| `Super + Shift + F` | File manager |
| `Super + Shift + N` | Editor |
| `Super + Shift + D` | Docker |
| `Super + W` | Close window |
| `Super + T` | Toggle floating / tiling |
| `Super + F` | Full screen |
| `Super + - / =` | Resize window (add `Shift` for the other axis) |
| `Super + Shift + Space` | Toggle top bar |
| `Super + Ctrl + L` | Lock |
| `Super + Ctrl + T` | Activity |
| `Super + Ctrl + V` | Clipboard manager |
| `Super + Ctrl + E` | Emoji picker |
| `Super + C / V / X` | Universal copy / paste / cut |
| `Print` | Screenshot |
| `Super + Print` | Color picker |
| `Super + S` | Toggle scratchpad |

---

## tmux

Config: [`tmux/tmux.conf`](../tmux/tmux.conf). Prefix is **`Ctrl-b`**
(on the Cornix: hold right Space, tap B).

| Keys | Action |
|---|---|
| `Ctrl + H/J/K/L` | Move between panes and Neovim splits (no prefix) |
| `prefix c` | New window in the current folder |
| `prefix Tab` | Last window |
| `prefix Ctrl-p` / `prefix Ctrl-n` | Previous / next window (Cornix combos A+B / S+B) |
| `prefix <` / `prefix >` | Move window left / right |
| `prefix \|` / `prefix _` | Split side by side / one above the other |
| `prefix h/j/k/l` | Select pane |
| `prefix H/J/K/L` | Resize pane by 5 |
| `prefix x` / `prefix X` | Kill pane / kill window (asks first) |
| `prefix f` | Sessionizer: pick a project, open or switch to its session |
| `prefix C` | New named session in the current folder |
| `prefix S` | Jump to session (fzf) |
| `prefix n` | Rename session |
| `prefix Q` | Kill session (asks first) |
| `prefix D` | Clear saved resurrect sessions (asks first) |
| `prefix g` | Lazygit popup |
| `prefix p` | Floating pane (floax) |
| `prefix Space` | Thumbs: hint-and-copy text on screen |
| `prefix v` | Copy mode (`v` select, `y` copy) |
| `prefix r` | Reload config |

---

## Neovim

LazyVim, config in [`nvim/`](../nvim). Leader is `Space`. Only my additions
and changes are listed; LazyVim's defaults (`<leader>ff`, `<leader>gg`, …)
still apply.

### Harpoon

| Keys | Action |
|---|---|
| `<leader>a` | Add current file |
| `<leader>1 … 4` / `Alt + 1 … 4` | Jump to file 1–4 (Cornix: layer 4 + A/S/D/F) |
| `<leader>h1 … h4` | Put current file in slot 1–4 |
| `<leader>hh` | Harpoon files in a picker with preview |
| `<leader>hc` | Clear the list |
| `Ctrl + e` | Harpoon menu |
| `Ctrl + p` / `Ctrl + n` | Previous / next Harpoon file (Cornix: layer 4 knob) |

A bar at the top shows the Harpoon files (` 1 main.py · 2 cli.py `) with the
current one highlighted, plus tab numbers when more than one tab is open.

### Other custom keys

| Keys | Action |
|---|---|
| `Ctrl + /` | Floating terminal (toggle) |
| `Ctrl + s` | Save without formatting |
| `Tab` / `Shift + Tab` | Next / previous buffer |
| `<leader>sv` / `<leader>sh` | Split vertical / horizontal |
| `<leader>sq` / `<leader>se` | Close split / equalize splits |
| `<leader>-` | Oil file browser (floating) |
| `<leader>o` | Code outline (Aerial) |
| `{` / `}` | Previous / next symbol |
| `<leader>j` | Jump list |
| `<leader>fb` | Buffers |
| `<leader>m` / `<leader>mm` | Maven / Maven panel |
| `<leader>jp` | Switch Maven profile |
| `<leader>cv` | Select Python virtualenv |

---

## Neovide

Neovide runs the same Neovim config, plus a **tmux-style `Ctrl-b` prefix**, so
the keys from the tmux section work here too. Tabs stand in for tmux windows.
Like tmux, the prefix waits for the next key with no timeout. Config:
[`nvim/lua/config/neovide_prefix.lua`](../nvim/lua/config/neovide_prefix.lua).

| Keys | Action |
|---|---|
| `Ctrl-b c` | New tab |
| `Ctrl-b Tab` | Last tab |
| `Ctrl-b 1 … 9` | Go to tab |
| `Ctrl-b Ctrl-p` / `Ctrl-b Ctrl-n` | Previous / next tab (Cornix combos A+B / S+B) |
| `Ctrl-b <` / `Ctrl-b >` | Move tab |
| `Ctrl-b \|` / `Ctrl-b _` | Split side by side / one above the other |
| `Ctrl-b h/j/k/l` | Move between splits |
| `Ctrl-b H/J/K/L` | Resize split |
| `Ctrl-b x` / `Ctrl-b X` | Close split / close tab |
| `Ctrl-b g` | Lazygit |
| `Ctrl-b p` | Floating terminal |
| `Ctrl-b f` | Projects |
| `Ctrl-b S` | Sessions |
| `Ctrl + = / - / 0` | Zoom in / out / reset |
| `Ctrl + Shift + v` | Paste from clipboard |

In Neovide, normal-mode `Ctrl-b` no longer pages up. It still scrolls an open
hover popup.

---

## Terminals: Ghostty and kitty

| Keys | Action | Where |
|---|---|---|
| `Ctrl + Insert` / `Shift + Insert` | Copy / paste | both |
| `Shift + Enter` | Sends `CSI 13;2u`, so TUIs can tell Shift+Enter from Enter | both |
| `Alt + Shift + Enter` | Sends `CSI 13;4u` | both |
| `Super + Ctrl + Shift + Alt + arrows` | Resize split | Ghostty |
