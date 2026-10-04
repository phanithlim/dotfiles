# What I changed from Omarchy's defaults

Omarchy loads its own defaults first, and the files in this repo layer on top.
This page lists every change and the reason for it, so I can rebuild the setup
after `omarchy refresh …`, a reinstall, or on a new machine.

- [Hyprland](#hyprland)
- [Quickshell bar (Omarchy shell)](#quickshell-bar-omarchy-shell)
- [Neovim](#neovim)
- [Neovide](#neovide)
- [tmux](#tmux)
- [Terminals: Ghostty and kitty](#terminals-ghostty-and-kitty)
- [Prompt (Starship)](#prompt-starship)
- [Keyboard (Cornix LP)](#keyboard-cornix-lp)

---

## Hyprland

Files: [`hypr/`](../hypr) → `~/.config/hypr/`

| File | Change |
|---|---|
| `hyprland.lua` | Loads Omarchy defaults, then my files below. Window rules: QEMU opens on workspace 5; Telegram doesn't steal focus; KeyStore Explorer main window maximized, dialogs float. **All windows fully opaque** (Omarchy defaults to 0.985 / 0.96). |
| `bindings.lua` | Vim focus on `Super + H/J/K/L` (Omarchy's J/K/L bindings removed). `Super + N` Neovide, `Super + Alt + L` workspace layout toggle, Obsidian relaunched with `-disable-gpu --enable-wayland-ime`. |
| `input.lua` | Layouts `us,kh` (English + Khmer) switched with `Alt + Shift`. Key repeat 40/s after 600 ms, numlock on, touchpad scroll 0.4. Terminal scroll speed: kitty/Alacritty/foot 1.5, Ghostty 0.2. |
| `looknfeel.lua` | Gaps: 2 inside; outside 8 left/right/bottom and **0 at the top**, so windows sit flush under the bar. Border 2, rounding 8. Apps can't pull focus to themselves. VRR off. |
| `monitors.lua` | Built-in display scale 1.25 (`GDK_SCALE` 1). `HDMI-A-1` at 1920×1080@60, scale 1.0. |
| `split-monitor-workspaces.lua` | Each monitor gets its own workspaces 1–10 (dwm/awesome style). `Super + Tab` cycles only occupied workspaces. Monitor focus/send bindings. See [keybindings](keybindings.md#hyprland-omarchy). |
| `hyprsunset.conf` | No tint by default (identity profile); night light only when toggled. |
| `xdph.conf` | Screen sharing: allow tokens by default, use `hyprland-preview-share-picker`. |
| `autostart.lua` | Nothing active (only commented examples). |

**Plugin needed — split-monitor-workspaces** (not stored in this repo):

```bash
git clone https://github.com/zjeffer/split-monitor-workspaces \
  ~/.config/hypr/plugins/split-monitor-workspaces
cd ~/.config/hypr/plugins/split-monitor-workspaces
git checkout release/0.56.x   # match your Hyprland minor version
```

After every Hyprland update: `git fetch -Ppft && git checkout release/<minor>.x && git pull`.

---

## Quickshell bar (Omarchy shell)

Files: [`omarchy/`](../omarchy) → `~/.config/omarchy/`

| Setting | Value |
|---|---|
| Position | Top, transparent background |
| Left | Omarchy menu, **`mlue.workspaces`** (my plugin) |
| Center | Indicators, clock (`ddd d MMM h:mm AP`, click for `d MMMM 'W'ww yyyy`), keyboard layout, weather, system update |
| Right | Tray, agents, Bluetooth, network, audio, monitor, battery with percentage |
| Idle | Screensaver after 150 s, lock after 300 s |
| Lock screen | Omarchy's lock disabled; **lock-explorer** plugin with the `editorial` design |
| Font | `shell.toml`: base size 14 |

**`mlue.workspaces`** ([`omarchy/plugins/mlue.workspaces`](../omarchy/plugins/mlue.workspaces))
is cloned from `omarchy.workspaces` and changed to work with
split-monitor-workspaces: each bar shows only its own monitor's workspaces,
labelled 1–10, with slots 1–5 always visible.
`workspacesPerMonitor` must match `workspace_count` in `hypr/split-monitor-workspaces.lua`.

**Plugin needed — lock-explorer** (not stored in this repo):

```bash
git clone https://github.com/SirJul1337/omarchy-lock-explorer.git \
  ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer
```

`shell.json` points the lock-screen avatar at an image in `~/Downloads`. Fix
that path on a new machine.

---

## Neovim

Files: [`nvim/`](../nvim) → `~/.config/nvim/`. LazyVim with 27 extras (`lazyvim.json`).

| Area | Change | File |
|---|---|---|
| Theme | Follows the Omarchy theme and reloads when it changes; transparency applied on top | `plugins/omarchy-theme-hotreload.lua`, `transparency.lua` |
| Terminal colours | `:terminal` uses the Omarchy palette; separate Starship config without `$fill` | `config/terminal_colors.lua`, `starship-nvim.toml` |
| Terminal | `Ctrl + /` opens a centred rounded float | `plugins/terminal.lua` |
| Terminal splits | `:terminal` splits get a darker background, ` TERMINAL · folder` header and left padding | `config/terminal_panel.lua` |
| Harpoon | Lists keyed by git root; Alt+1–4, slot keys, picker, marks bar at the top | `plugins/harpoon.lua`, `config/harpoon_bar.lua` |
| Navigation | vim-tmux-navigator: `Ctrl + H/J/K/L` crosses Neovim/tmux | `plugins/vim-tmux-navigator.lua` |
| Dashboard | dashboard-nvim with the MLUE logo (snacks dashboard off) | `plugins/ui.lua`, `plugins/explorer.lua` |
| Removed | bufferline, markview, markdown-preview, render-markdown, real-icons | `plugins/ui.lua` |
| Notify filter | Hides the noisy "Can't set 'path'" message. Installed after startup, because wrapping `vim.notify` earlier made LazyVim loop and use 20+ GB of RAM | `config/options.lua` |
| Java | jdtls, Spring Boot, Maven panel and profile switching | `plugins/nvim-jdtls.lua`, `plugins/spring-boot.lua`, `plugins/maven-panel.lua` |

---

## Neovide

Files: [`neovide/config.toml`](../neovide/config.toml) → `~/.config/neovide/`,
plus the Neovide block in `nvim/lua/config/options.lua`.

- JetBrainsMono Nerd Font 14, full window frame, forks from the terminal.
- `Ctrl + = / - / 0` zoom, `Ctrl + Shift + v` paste.
- Short cursor animation (0.05 s) and scroll animation (0.2 s).
- **tmux-style `Ctrl-b` prefix**, so tmux muscle memory works in Neovide
  (`config/neovide_prefix.lua`). noice's normal-mode `Ctrl-b` is turned off in
  Neovide only (`plugins/neovide.lua`).

---

## tmux

Files: [`tmux/tmux.conf`](../tmux/tmux.conf) → `~/.config/tmux/`,
[`bin/tmux-sessionizer`](../bin/tmux-sessionizer) → `~/.local/bin/`.

- Prefix `Ctrl-b`, windows and panes numbered from 1, status bar at the top,
  50,000 lines of history, mouse on, vi copy mode.
- Plugins (installed by tpm, `prefix I`): sensible, yank, catppuccin, fzf,
  fzf-url, floax, dotbar, vim-tmux-navigator, resurrect, continuum, thumbs.
- Thumbs copies git hashes and IP addresses straight to the Wayland clipboard.
- `prefix Ctrl-p` / `Ctrl-n` added for the Cornix combos.
- `tmux-sessionizer` lists projects under `~/Documents/{tsc,ai,projects}`
  plus the Neovim and tmux config folders.

Install tpm on a new machine:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# then start tmux and press prefix + I
```

---

## Terminals: Ghostty and kitty

Files: [`ghostty/config`](../ghostty/config), [`kitty/kitty.conf`](../kitty/kitty.conf) → `~/.config/…`

Both:
- Use the current Omarchy theme file.
- JetBrainsMono Nerd Font 11.
- Horizontal padding 12, no confirmation when closing.
- Non-blinking cursor, shell-integration cursor off.
- `Ctrl/Shift + Insert` copy/paste.
- `Shift + Enter` sends `CSI 13;2u`.

| | Ghostty | kitty |
|---|---|---|
| Cursor | Block | Beam |
| Extra | `TERM=xterm-256color`, SSH terminfo/env integration, `epoll` backend, split resize with all modifiers + arrows | Khmer glyphs from Noto Sans Khmer, powerline tab bar at the bottom, no window decorations, remote control socket for Omarchy |

---

## Prompt (Starship)

[`starship.toml`](../starship.toml) for normal shells.
[`starship-nvim.toml`](../starship-nvim.toml) for Neovim's `:terminal`: no `$fill`, because the
right-aligned part garbles when a terminal window is resized.

---

## Keyboard (Cornix LP)

[`keyboard/cornix/mycurrent-cornix.vil`](../keyboard/cornix/mycurrent-cornix.vil),
loaded with Vial. Full map and reasoning in [keyboard-cornix.md](keyboard-cornix.md).
