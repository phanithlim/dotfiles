# Remove kitty's padding while nvim or tmux runs.
# Only with a kitty socket: herdr panes have none, and `kitty @` would hang 10 s.

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
