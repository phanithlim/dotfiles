# Troubleshooting

## Neovim takes 10 seconds to open or quit in herdr

**Symptom:** in a herdr pane, `nvim` shows a blank screen with a cursor for about 10 seconds before the dashboard. Quitting waits about 10 seconds too. `nvim --clean` is just as slow, but `/usr/bin/nvim` opens instantly.

**Cause:** `~/.bashrc` wraps `nvim` and `tmux` in functions that run `kitty @ set-spacing` to change kitty's padding, once before the program starts and once after it exits. Herdr panes have no `KITTY_LISTEN_ON`, so `kitty @` has no socket. It waits for a reply that never comes, then times out after 10 seconds. It isn't Neovim, the plugins or herdr itself.

**Fix:** only call `kitty @` when a kitty socket exists. `.bashrc` isn't tracked in this repo, so apply this by hand on a new machine:

```bash
# Only with a kitty socket: in herdr, `kitty @` has none and blocks 10s until it times out.
nvim() {
  if [ -z "$TMUX" ] && [ -n "$KITTY_LISTEN_ON" ]; then
    kitty @ set-spacing padding=0 2>/dev/null
    command nvim "$@"
    kitty @ set-spacing padding=default 2>/dev/null
  else
    command nvim "$@"
  fi
}

tmux() {
  if [ -n "$KITTY_LISTEN_ON" ]; then
    kitty @ set-spacing padding=0 2>/dev/null
    command tmux "$@"
    kitty @ set-spacing padding=default 2>/dev/null
  else
    command tmux "$@"
  fi
}
```

Panes that are already open keep the old functions until you run `source ~/.bashrc`.

**Result:** opening went from 10.15s to about 0.1s, and quitting from about 10s to 0.06s.

**If a command is slow only inside herdr:** check whether it's a shell function with `type <command>`, then compare it with the real binary (`/usr/bin/<command>`). Timing a trivial command in the same pane shows whether the delay is in the shell or the program.

## Hyprland drops to defaults after a reload

**Symptom:** after `hyprctl reload`, keybinds, gaps, rounding and the keyboard layout reset. `hyprctl binds` lists only `Super+Q/R/M`, while `hyprctl configerrors` stays empty.

**What happened:** this came up on 2026-11-05 right after adding a window rule with `border_size = 0` to `hyprland.lua`. Removing the rule and reloading restored everything. The cause wasn't confirmed, and an error-free reload doesn't prove the config loaded.

**Check after a reload:**

```bash
hyprctl binds -j | jq length          # hundreds expected, not 3
hyprctl getoption general:border_size # should show "set": true
```

Check again after a moment, because the fallback didn't show up immediately.
