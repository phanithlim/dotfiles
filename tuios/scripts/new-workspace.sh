#!/usr/bin/env bash
s="${TUIOS_SESSION:?}"
used=$(tuios list-windows -s "$s" --json | jq -r '.windows[].workspace' | sort -u)
for i in 1 2 3 4 5 6 7 8 9; do
  if ! grep -qx "$i" <<<"$used"; then
    tuios new-window -s "$s" --workspace "$i" --cwd "${TUIOS_ACTIVE_PANE_CWD:-$HOME}" >/dev/null
    tuios select-workspace -s "$s" "$i" >/dev/null
    exit 0
  fi
done
echo "All 9 workspaces are in use" >&2
exit 1
