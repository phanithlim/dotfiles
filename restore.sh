#!/usr/bin/env bash
#
# Copy the configs in this repo back onto this computer.
#
#   ./restore.sh           Show what would change. Nothing is written.
#   ./restore.sh --apply   Save a backup, then copy the files.
#
# Files that exist only on this computer are never deleted.

# Stop at the first error.
set -e

# Run from the repo folder, wherever the script was started.
cd "$(dirname "$0")"

MODE="$1"
CONFIG="$HOME/.config"
VAULT="$HOME/Documents/brain/mluespace"
BACKUP="$HOME/.local/state/dotfiles-restore/$(date +%Y%m%d-%H%M%S)"

# copy <file or folder in this repo> <where it goes>
copy() {
  if [ "$MODE" = "--apply" ]; then
    rsync -rlpD --checksum --mkpath --backup --backup-dir="$BACKUP$2" "$1" "$2"
  else
    rsync -rlpD --checksum --mkpath --dry-run --out-format="  %f" "$1" "$2"
  fi
}

copy omarchy/              "$CONFIG/omarchy/"
copy nvim/                 "$CONFIG/nvim/"
copy neovide/config.toml   "$CONFIG/neovide/"
copy tmux/tmux.conf        "$CONFIG/tmux/"
copy tmux/scripts/         "$CONFIG/tmux/scripts/"
copy tuios/                "$CONFIG/tuios/"
copy herdr/config.toml     "$CONFIG/herdr/"
copy lazydocker/config.yml "$CONFIG/lazydocker/"
copy ghostty/config        "$CONFIG/ghostty/"
copy kitty/kitty.conf      "$CONFIG/kitty/"
copy starship.toml         "$CONFIG/"
copy starship-nvim.toml    "$CONFIG/"
copy bin/tmux-sessionizer  "$HOME/.local/bin/"
copy bin/herdr-sessionizer "$HOME/.local/bin/"
copy ideavim/ideavimrc     "$HOME/.ideavimrc"

# Obsidian: only if the vault is on this computer.
if [ -d "$VAULT" ]; then
  copy obsidian/.obsidian.vimrc "$VAULT/"
  copy obsidian/app.json        "$VAULT/.obsidian/"
  copy obsidian/appearance.json "$VAULT/.obsidian/"
  copy obsidian/hotkeys.json    "$VAULT/.obsidian/"
  copy obsidian/snippets/       "$VAULT/.obsidian/snippets/"
  copy obsidian/plugins/        "$VAULT/.obsidian/plugins/"
fi

# Hyprland goes last: it reloads as soon as its files change.
copy hypr/ "$CONFIG/hypr/"

if [ "$MODE" != "--apply" ]; then
  echo
  echo "Preview only, nothing was written."
  echo "To copy these files, run: ./restore.sh --apply"
  exit 0
fi

echo "Done. Replaced files were saved in: $BACKUP"

# Reload, but only when running inside a Hyprland desktop.
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  hyprctl reload >/dev/null
  omarchy restart shell
  omarchy restart terminal

  # A broken config can fall back to defaults without showing an error.
  # A working setup has hundreds of keybinds. The fallback has only a few.
  BINDS=$(hyprctl binds -j | jq length)
  if [ "$BINDS" -lt 20 ]; then
    echo "WARNING: only $BINDS keybinds loaded, so Hyprland may have failed."
    echo "To undo: cp -r $BACKUP$CONFIG/hypr/. $CONFIG/hypr/ && hyprctl reload"
    exit 1
  fi
fi

echo
echo "Still to do by hand (see README and docs/troubleshooting.md):"
echo "  - Add the kitty fix to ~/.bashrc if it is not there yet"
echo "  - Install plugins, load the keyboard layout, set the lock-screen avatar"
