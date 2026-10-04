#!/usr/bin/env bash
branch=$(git -C "$1" branch --show-current 2>/dev/null) || exit 0
[[ -n $branch ]] || exit 0
(( ${#branch} > 20 )) && branch="${branch:0:19}…"
printf '#[fg=%s,bg=default]#[fg=%s,bg=%s] #[fg=%s,bg=%s] %s #[fg=%s,bg=default] ' "$2" "$3" "$2" "$5" "$4" "$branch" "$4"
