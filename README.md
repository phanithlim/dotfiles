# Dotfiles

Arch + Omarchy (Hyprland), Neovim, tmux/herdr, kitty, IntelliJ, Cornix LP keyboard.

![Cornix LP](assets/cornix.webp)

Docs: [keys](docs/keys.md) · [Cornix layers](docs/keyboard-cornix.md)

## Use

```bash
./restore.sh           # preview what would change
./restore.sh --apply   # back up, copy configs to this computer, reload
./save.sh              # copy this computer's configs into the repo
```

## New machine

```bash
gh repo clone phanithlim/docs ~/Documents/brain/mluespace   # notes vault, before restore
./restore.sh --apply

# plugins (split-monitor branch must match your Hyprland version)
git clone -b release/0.56.x https://github.com/zjeffer/split-monitor-workspaces ~/.config/hypr/plugins/split-monitor-workspaces
git clone https://github.com/SirJul1337/omarchy-lock-explorer.git ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm   # then prefix + I in tmux

echo 'source ~/Projects/dotfiles/bash/kitty-padding.sh' >> ~/.bashrc
```

Then load `keyboard/cornix/mycurrent-cornix-symbols.vil` in Vial, and fix the lock-screen avatar path in `omarchy/shell.json`.
