# Dotfiles

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=archlinux&logoColor=white) ![Omarchy](https://img.shields.io/badge/Omarchy-1e1e2e?style=flat-square) ![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat-square&logo=hyprland&logoColor=black) ![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat-square&logo=neovim&logoColor=white) ![LazyVim](https://img.shields.io/badge/LazyVim-2E7DE9?style=flat-square) ![tmux](https://img.shields.io/badge/tmux-1BB91F?style=flat-square&logo=tmux&logoColor=white) ![kitty](https://img.shields.io/badge/kitty-4C4C4C?style=flat-square) ![IntelliJ IDEA](https://img.shields.io/badge/IntelliJ_IDEA-000000?style=flat-square&logo=intellijidea&logoColor=white) ![Catppuccin](https://img.shields.io/badge/Catppuccin-F5C2E7?style=flat-square) ![Cornix LP](https://img.shields.io/badge/Cornix_LP-FAB387?style=flat-square)

![Cornix LP](assets/cornix.webp)

| Doc | |
|---|---|
| [Keybindings](docs/keybindings.md) | Hyprland, tmux, Neovim, Neovide, IntelliJ |
| [Keyboard](docs/keyboard-cornix.md) | Cornix LP layers, knobs, combos |
| [IdeaVim](docs/ideavim.md) | IdeaVim keys and IntelliJ settings |
| [Troubleshooting](docs/troubleshooting.md) | Slow Neovim in herdr, Hyprland reload fallback |

## What's here

| Folder | Goes to |
|---|---|
| `hypr/` | `~/.config/hypr/` |
| `omarchy/` | `~/.config/omarchy/` |
| `nvim/` | `~/.config/nvim/` |
| `neovide/` | `~/.config/neovide/` |
| `tmux/` | `~/.config/tmux/` |
| `tuios/` | `~/.config/tuios/` |
| `herdr/` | `~/.config/herdr/` |
| `lazydocker/` | `~/.config/lazydocker/` |
| `ghostty/`, `kitty/` | `~/.config/ghostty/`, `~/.config/kitty/` |
| `starship*.toml` | `~/.config/` |
| `bin/` | `~/.local/bin/` |
| `ideavim/ideavimrc` | `~/.ideavimrc` (IntelliJ) |
| `keyboard/cornix/*.vil` | Vial |
| `obsidian/` | vault: `.obsidian.vimrc` and `.marksman.toml` in the vault root, the rest in `.obsidian/` |

## Setup

**1. Copy configs**

`./restore.sh` previews what would change. `./restore.sh --apply` backs up the files it replaces, copies everything below, reloads and checks Hyprland.

Or by hand:

```bash
cd ~/Projects/dotfiles
cp hypr/* ~/.config/hypr/
cp -r omarchy/* ~/.config/omarchy/
rsync -a nvim/ ~/.config/nvim/
cp neovide/config.toml ~/.config/neovide/
cp -r tmux/tmux.conf tmux/scripts ~/.config/tmux/
mkdir -p ~/.config/tuios && cp -r tuios/* ~/.config/tuios/
mkdir -p ~/.config/herdr && cp herdr/config.toml ~/.config/herdr/
mkdir -p ~/.config/lazydocker && cp lazydocker/config.yml ~/.config/lazydocker/
cp ghostty/config ~/.config/ghostty/
cp kitty/kitty.conf ~/.config/kitty/
cp starship*.toml ~/.config/
install -m 755 bin/tmux-sessionizer bin/herdr-sessionizer ~/.local/bin/
cp ideavim/ideavimrc ~/.ideavimrc
V=~/Documents/brain/mluespace; cp obsidian/.obsidian.vimrc obsidian/.marksman.toml $V/ && cp -r obsidian/{*.json,snippets,plugins} $V/.obsidian/
```

**2. Install plugins**

```bash
# Hyprland: per-monitor workspaces (branch must match your Hyprland version)
git clone -b release/0.56.x https://github.com/zjeffer/split-monitor-workspaces ~/.config/hypr/plugins/split-monitor-workspaces

# Bar: lock screen
git clone https://github.com/SirJul1337/omarchy-lock-explorer.git ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer

# Obsidian: plugins (then turn them on in Settings -> Community plugins)
P=~/Documents/brain/mluespace/.obsidian/plugins
gh release download -R zsviczian/obsidian-excalidraw-plugin -p main.js -p manifest.json -p styles.css -D $P/obsidian-excalidraw-plugin --clobber
gh release download -R ryotaushio/obsidian-pdf-plus -p main.js -p manifest.json -p styles.css -D $P/pdf-plus --clobber
gh release download -R YishenTu/claudian -p main.js -p manifest.json -p styles.css -D $P/realclaudian --clobber
gh release download -R johansan/notebook-navigator -p main.js -p manifest.json -p styles.css -D $P/notebook-navigator --clobber
gh release download -R Vinzent03/obsidian-git -p main.js -p manifest.json -p styles.css -D $P/obsidian-git --clobber
# Obsidian: Inter font and git access for the vault (notes live in phanithlim/docs)
omarchy pkg add inter-font
git -C ~/Documents/brain/mluespace config credential.helper '!gh auth git-credential'

# tmux: plugin manager (then press prefix + I inside tmux)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

**3. Keyboard**: Vial → File → Load saved layout → `keyboard/cornix/mycurrent-cornix-symbols.vil`

**4. Reload**

| What | Command |
|---|---|
| Hyprland | `hyprctl reload` |
| Bar | `omarchy restart shell` |
| Terminals | `omarchy restart terminal` |
| tmux | `prefix r` |
| tuios | automatic on save |
| Neovim | restart |

**5. Fix by hand**: lock-screen avatar path in `omarchy/shell.json`

## Update from live configs

```bash
cd ~/Projects/dotfiles
cp ~/.config/hypr/{hyprland,bindings,input,looknfeel,monitors,autostart,split-monitor-workspaces}.lua ~/.config/hypr/{hyprsunset,xdph}.conf hypr/
cp ~/.config/omarchy/shell.{json,toml} omarchy/
cp -r ~/.config/omarchy/plugins/mlue.workspaces ~/.config/omarchy/plugins/mlue.keyboard-layout omarchy/plugins/
cp ~/.config/omarchy/hooks/theme-set.d/tmux-colors omarchy/hooks/theme-set.d/
rsync -a --delete --exclude .git --exclude .claude --exclude '*.bak*' ~/.config/nvim/ nvim/
cp ~/.config/neovide/config.toml neovide/
cp -r ~/.config/tmux/tmux.conf ~/.config/tmux/scripts tmux/
cp -r ~/.config/tuios/config.toml ~/.config/tuios/glyphs ~/.config/tuios/scripts tuios/
cp ~/.config/herdr/config.toml herdr/
cp ~/.config/lazydocker/config.yml lazydocker/
cp ~/.config/ghostty/config ghostty/
cp ~/.config/kitty/kitty.conf kitty/
cp ~/.config/starship.toml ~/.config/starship-nvim.toml .
sed -E 's| ~/Documents/tsc/[^ ]+||g' ~/.local/bin/tmux-sessionizer > bin/tmux-sessionizer   # drops private project folders
sed -E 's| ~/Documents/tsc/[^ ]+||g' ~/.local/bin/herdr-sessionizer > bin/herdr-sessionizer   # drops private project folders
cp ~/Documents/cornix/mycurrent-cornix-symbols.vil keyboard/cornix/
cp ~/.ideavimrc ideavim/ideavimrc
V=~/Documents/brain/mluespace; cp $V/.obsidian.vimrc $V/.marksman.toml obsidian/ && cp $V/.obsidian/{app,appearance,hotkeys,community-plugins,templates,daily-notes}.json obsidian/ && cp $V/.obsidian/snippets/*.css obsidian/snippets/ && for p in notebook-navigator obsidian-git obsidian-excalidraw-plugin; do cp $V/.obsidian/plugins/$p/data.json obsidian/plugins/$p/; done
python3 ideavim/ideavim2md.py ~/.ideavimrc > docs/ideavim.md   # IdeaVim key notes
python3 keyboard/cornix/vil2md.py keyboard/cornix/mycurrent-cornix-symbols.vil   # paste over the layer tables in docs/keyboard-cornix.md
python3 -B keyboard/cornix/cheatsheet.py keyboard/cornix/mycurrent-cornix-symbols.vil > docs/cornix-cheatsheet.md   # Super+Ctrl+/ cheat sheet
python3 strip-comments.py   # repo copies are kept without comments
```
