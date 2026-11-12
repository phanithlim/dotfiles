#!/usr/bin/env bash
#
# Copy the configs on this computer into this repo.
# The opposite of restore.sh. Check the result with: git diff
#
#   ./save.sh

# Stop at the first error.
set -e

# Run from the repo folder, wherever the script was started.
cd "$(dirname "$0")"

CONFIG="$HOME/.config"
VAULT="$HOME/Documents/brain/mluespace"

# Hyprland
cp "$CONFIG"/hypr/{hyprland,bindings,input,looknfeel,monitors,autostart,split-monitor-workspaces}.lua hypr/
cp "$CONFIG"/hypr/{hyprsunset,xdph}.conf hypr/

# Omarchy bar, plugins and hooks
cp "$CONFIG"/omarchy/shell.{json,toml} omarchy/
cp -r "$CONFIG"/omarchy/plugins/{mlue.workspaces,mlue.keyboard-layout,mlue.menu} omarchy/plugins/
cp "$CONFIG"/omarchy/hooks/theme-set.d/{tmux-colors,lazygit-icons} omarchy/hooks/theme-set.d/

# Editors and terminals
rsync -a --delete --exclude .git --exclude .claude --exclude '*.bak*' "$CONFIG/nvim/" nvim/
cp "$CONFIG"/neovide/config.toml neovide/
cp "$HOME"/.ideavimrc ideavim/ideavimrc
cp -r "$CONFIG"/tmux/tmux.conf "$CONFIG"/tmux/scripts tmux/
cp -r "$CONFIG"/tuios/{config.toml,glyphs,scripts} tuios/
cp "$CONFIG"/herdr/config.toml herdr/
cp "$CONFIG"/lazydocker/config.yml lazydocker/
cp "$CONFIG"/lazygit/config.yml lazygit/
cp "$CONFIG"/ghostty/config ghostty/
cp "$CONFIG"/kitty/kitty.conf kitty/
cp "$CONFIG"/starship.toml "$CONFIG"/starship-nvim.toml .

# Leftover backup files never belong in the repo.
find tmux/scripts -name '*.bak*' -delete

# Sessionizers, without the private project folders.
for s in tmux-sessionizer herdr-sessionizer; do
  sed -E 's| ~/Documents/tsc/[^ ]+||g' "$HOME/.local/bin/$s" > "bin/$s"
done

# Keyboard layout (saved from Vial).
cp "$HOME"/Documents/cornix/mycurrent-cornix-alt.vil keyboard/cornix/

# Obsidian: only if the vault is on this computer.
if [ -d "$VAULT" ]; then
  cp "$VAULT"/{.obsidian.vimrc,.marksman.toml} obsidian/
  cp "$VAULT"/.obsidian/{app,appearance,hotkeys,community-plugins,templates,daily-notes}.json obsidian/
  cp "$VAULT"/.obsidian/snippets/*.css obsidian/snippets/
  for p in notebook-navigator obsidian-git obsidian-excalidraw-plugin; do
    cp "$VAULT/.obsidian/plugins/$p/data.json" "obsidian/plugins/$p/"
  done
fi

echo "Saved. Review with: git diff"
