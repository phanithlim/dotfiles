#!/usr/bin/env bash
# Git branch pill for the tmux bar; prints nothing outside a git repo.
# Shows the branch plus ●N uncommitted files, ↑N ahead and ↓N behind upstream.
# usage: git-pill <path> <icon-bg> <icon-fg> <surface> <text> [<warn>]
status=$(git -C "$1" status --porcelain=v2 --branch 2>/dev/null) || exit 0
branch=$(sed -n 's/^# branch.head //p' <<<"$status")
[[ $branch == "(detached)" ]] && branch=$(git -C "$1" rev-parse --short HEAD 2>/dev/null)
[[ -n $branch ]] || exit 0
(( ${#branch} > 20 )) && branch="${branch:0:19}…"

warn=${6:-$5}
extra=""
dirty=$(grep -vc '^#' <<<"$status")
read -r ahead behind < <(sed -n 's/^# branch.ab +\([0-9]*\) -\([0-9]*\)/\1 \2/p' <<<"$status")
(( dirty > 0 )) && extra+=" ●$dirty"
(( ${ahead:-0} > 0 )) && extra+=" ↑$ahead"
(( ${behind:-0} > 0 )) && extra+=" ↓$behind"
[[ -n $extra ]] && extra="#[fg=$warn]$extra"

printf '#[fg=%s,bg=default]#[fg=%s,bg=%s] #[fg=%s,bg=%s] %s%s #[fg=%s,bg=default] ' \
  "$2" "$3" "$2" "$5" "$4" "$branch" "$extra" "$4"
