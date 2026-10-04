# Dotfiles

My setup on [Omarchy](https://omarchy.org/) (Arch + Hyprland), driven from a
Cornix LP split keyboard.

## Docs

| Doc | What's in it |
|---|---|
| [docs/keybindings.md](docs/keybindings.md) | Every key I use: Hyprland, tmux, Neovim, Neovide, terminals |
| [docs/customizations.md](docs/customizations.md) | What I changed from Omarchy's defaults, and why |
| [docs/keyboard-cornix.md](docs/keyboard-cornix.md) | Cornix LP layers, combos, macros and knobs |

## Layout

| In this repo | Goes to | What |
|---|---|---|
| `hypr/` | `~/.config/hypr/` | Hyprland overrides (Lua) |
| `omarchy/shell.json`, `omarchy/shell.toml` | `~/.config/omarchy/` | Quickshell bar, idle, lock screen |
| `omarchy/plugins/mlue.workspaces/` | `~/.config/omarchy/plugins/` | Per-monitor workspace bar widget |
| `nvim/` | `~/.config/nvim/` | Neovim (LazyVim) |
| `neovide/config.toml` | `~/.config/neovide/` | Neovide |
| `tmux/tmux.conf` | `~/.config/tmux/` | tmux |
| `ghostty/config` | `~/.config/ghostty/` | Ghostty |
| `kitty/kitty.conf` | `~/.config/kitty/` | kitty |
| `starship.toml`, `starship-nvim.toml` | `~/.config/` | Prompt (shell / Neovim terminal) |
| `bin/tmux-sessionizer` | `~/.local/bin/` | tmux project picker |
| `.bashrc` | `~/` | Bash |
| `keyboard/cornix/mycurrent-cornix.vil` | load in Vial | Cornix LP layout |

## Restore on a new machine

These are copies, not symlinks. Copy each item back to the location in the
table:

```bash
cd ~/dotfiles
cp hypr/*.lua hypr/*.conf ~/.config/hypr/
cp omarchy/shell.json omarchy/shell.toml ~/.config/omarchy/
cp -r omarchy/plugins/mlue.workspaces ~/.config/omarchy/plugins/
rsync -a nvim/ ~/.config/nvim/
cp neovide/config.toml ~/.config/neovide/
cp tmux/tmux.conf ~/.config/tmux/
cp ghostty/config ~/.config/ghostty/
cp kitty/kitty.conf ~/.config/kitty/
cp starship.toml starship-nvim.toml ~/.config/
install -m 755 bin/tmux-sessionizer ~/.local/bin/
```

Three things live outside this repo and need installing:

1. **split-monitor-workspaces** (Hyprland)
2. **lock-explorer** (Omarchy shell)
3. **tpm** (tmux)

The commands for each are in [customizations.md](docs/customizations.md).

Then reload everything:
- Hyprland: `hyprctl reload`
- Bar: `omarchy restart shell`
- Terminals: `omarchy restart terminal`
- tmux: `prefix r`
- Keyboard: Vial → **File → Load saved layout**

## Update this repo from the live configs

```bash
cd ~/dotfiles
cp ~/.config/hypr/{hyprland,bindings,input,looknfeel,monitors,autostart,split-monitor-workspaces}.lua ~/.config/hypr/{hyprsunset,xdph}.conf hypr/
cp ~/.config/omarchy/shell.{json,toml} omarchy/
cp -r ~/.config/omarchy/plugins/mlue.workspaces omarchy/plugins/
rsync -a --delete --exclude .git --exclude .claude --exclude '*.bak*' ~/.config/nvim/ nvim/
cp ~/.config/neovide/config.toml neovide/
cp ~/.config/tmux/tmux.conf tmux/
cp ~/.config/ghostty/config ghostty/
cp ~/.config/kitty/kitty.conf kitty/
cp ~/.config/starship.toml ~/.config/starship-nvim.toml .
cp ~/.local/bin/tmux-sessionizer bin/
cp ~/Documents/cornix/mycurrent-cornix.vil keyboard/cornix/
```
