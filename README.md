# Dotfiles

Personal configuration files for Arch Linux. This repository contains configurations for Hyprland, tmux, Starship prompt, and various utility scripts.

## Overview

This is a collection of configuration files tailored for a Hyprland-based workflow on Arch Linux, featuring a highly customized tmux setup with multiple plugins and a clean Starship prompt.

## Structure

```
.
├── hypr/              # Hyprland window manager configuration
├── tmux/              # Tmux terminal multiplexer setup
├── hooks/             # Pacman hooks for system maintenance
├── scripts/           # Utility scripts
└── starship.toml      # Starship prompt configuration
```

## Components

### Hyprland Configuration

Modular Hyprland configuration split into logical components:

- **autostart.conf** - Startup applications and services
- **bindings.conf** - Keyboard shortcuts and mouse bindings
- **looknfeel.conf** - Visual styling and animations
- **monitors.conf** - Multi-monitor setup
- **window.conf** - Window rules and workspace behavior
- **plugin-split-monitor-workspace.conf** - Split monitor workspace plugin settings

All configs assume Hyprland with hyprpm for plugin management.

### Tmux Setup

Heavily customized tmux configuration featuring:

**Core Settings:**
- Mouse support enabled
- 1,000,000 line history buffer
- Status bar positioned at top
- Smart window renumbering
- System clipboard integration

**Theme:**
- Catppuccin color scheme (mocha variant)
- tmux-dotbar for minimalist status bar
- Dynamic color adaptation

**Plugins:**
- **tpm** - Plugin manager
- **tmux-sensible** - Sensible defaults
- **tmux-yank** - Enhanced copy/paste
- **tmux-continuum** - Automatic session saving
- **tmux-fzf** - Fuzzy finder integration
- **tmux-fzf-url** - URL extraction and opening
- **tmux-dotbar** - Minimalist status bar
- **catppuccin/tmux** - Color theme

### Starship Prompt

Clean two-line prompt configuration:

- Top line: Directory path with git information
- Bottom line: Arch Linux icon with status indicator
- Color-coded git status and error states
- Fast response time (200ms timeout)

### Scripts

**header-gen.sh**
Generates formatted comment headers for configuration files:
- Box-style headers with borders
- Line-style section dividers
- Auto-centered text

**scl.sh**
SSH Config Manager for easy SSH connection management:
- List all configured hosts
- Quick connect with tab completion
- Add/remove hosts interactively
- Edit SSH config directly

**update-hyprpm.sh**
Updates Hyprland plugins via hyprpm. Used by pacman hook to rebuild plugins after Hyprland updates.

### Pacman Hooks

Automated system maintenance hooks:

**hyprland-plugins.hook**
Automatically rebuilds Hyprland plugins when Hyprland is upgraded to prevent compatibility issues.

See [hooks/README.md](hooks/README.md) for detailed installation instructions.

## Installation

### Prerequisites

```bash
# Core requirements
sudo pacman -S hyprland tmux starship

# Optional dependencies
sudo pacman -S fzf libnotify
```

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Hyprland (manual symlink):**
   ```bash
   ln -sf ~/.dotfiles/hypr ~/.config/hypr
   ```

3. **Tmux:**
   ```bash
   ln -sf ~/.dotfiles/tmux ~/.config/tmux
   
   # Install TPM (tmux plugin manager)
   git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
   
   # Start tmux and install plugins
   tmux
   # Press: Ctrl+B then Shift+I
   ```

4. **Starship:**
   ```bash
   ln -sf ~/.dotfiles/starship.toml ~/.config/starship.toml
   
   # Add to your shell RC file (.bashrc or .zshrc):
   echo 'eval "$(starship init bash)"' >> ~/.bashrc
   # or for zsh:
   echo 'eval "$(starship init zsh)"' >> ~/.zshrc
   ```

5. **Scripts (optional):**
   ```bash
   # Make scripts executable
   chmod +x ~/.dotfiles/scripts/*.sh
   
   # Add to PATH or source in shell RC:
   echo 'export PATH="$HOME/.dotfiles/scripts:$PATH"' >> ~/.bashrc
   ```

6. **Pacman Hooks (optional):**
   ```bash
   sudo cp hooks/hyprland-plugins.hook /etc/pacman.d/hooks/
   # Edit the hook file to replace <YOURNAME> with your username
   sudo nano /etc/pacman.d/hooks/hyprland-plugins.hook
   ```

## Configuration

### Changing Tmux Theme

Edit [tmux/tmux.conf](tmux/tmux.conf) line 29:

```bash
set -g @catppuccin_flavor 'mocha'  # Options: latte, frappe, macchiato, mocha
```

### Modifying Starship Prompt

Edit [starship.toml](starship.toml) to customize:
- Character symbols and colors
- Directory truncation length
- Git branch display
- Command timeout

### Adjusting Hyprland

Each aspect of Hyprland is modular:
- Keybindings: Edit [hypr/bindings.conf](hypr/bindings.conf)
- Appearance: Edit [hypr/looknfeel.conf](hypr/looknfeel.conf)
- Monitors: Edit [hypr/monitors.conf](hypr/monitors.conf)

## Usage

### SSH Config Manager

```bash
scl ls              # List all configured hosts
scl connect myhost  # Connect to a host
scl add             # Add a new host interactively
scl del myhost      # Remove a host
scl edit            # Edit SSH config file
```

### Header Generator

Source the script and use the functions:

```bash
source ~/.dotfiles/scripts/header-gen.sh
gen-header "My Section"
gen-line "Subsection"
```

## Notes

- All configurations assume a Catppuccin color scheme across tools
- Tmux prefix is set to default Ctrl+B
- Hyprland configurations expect hyprpm for plugin management
- SSH config manager assumes standard SSH config format

## License

Personal configuration files. Use at your own discretion.
