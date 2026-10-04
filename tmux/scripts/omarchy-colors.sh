#!/usr/bin/env bash
colors=~/.local/state/omarchy/current/theme/colors.toml
[[ -f $colors ]] || exit 0
tmux info >/dev/null 2>&1 || exit 0   # no tmux server: nothing to do

get() { sed -nE "s/^$1 *= *\"(#[0-9a-fA-F]{6})\".*/\1/p" "$colors" | head -1; }

tmux set -g @c_crust   "$(get darker_background)" \; \
     set -g @c_surface "$(get lighter_background)" \; \
     set -g @c_dim     "$(get dark_foreground)" \; \
     set -g @c_text    "$(get foreground)" \; \
     set -g @c_accent  "$(get accent)" \; \
     set -g @c_green   "$(get green)" \; \
     set -g @c_mauve   "$(get magenta)" \; \
     set -g @c_yellow  "$(get yellow)" \; \
     set -g @c_peach   "$(get orange)" \; \
     set -g @floax-border-color "$(get accent)" \; \
     set -g @floax-text-color "$(get foreground)" \; \
     set -g @thumbs-fg-color "$(get foreground)" \; \
     set -g @thumbs-hint-fg-color "$(get accent)" \; \
     set -g @thumbs-select-fg-color "$(get green)"
tmux refresh-client -S 2>/dev/null
exit 0
