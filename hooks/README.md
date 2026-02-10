# Pacman Hooks

This directory contains pacman hooks for automatically maintaining system configurations.

## hyprland-plugins.hook

A pacman hook that automatically rebuilds Hyprland plugins when Hyprland is upgraded.

### Purpose

When Hyprland is updated, plugins compiled against the previous version may become incompatible. This hook ensures that all hyprpm-managed plugins are automatically rebuilt after any Hyprland upgrade, preventing crashes and compatibility issues.

### Installation

1. **Install the hook:**
   ```bash
   sudo cp hyprland-plugins.hook /etc/pacman.d/hooks/
   ```

2. **Copy the update script:**
   ```bash
   cp ../scripts/update-hyprpm.sh ~/.config/
   chmod +x ~/.config/update-hyprpm.sh
   ```

3. **Edit the hook file:**
   ```bash
   sudo nano /etc/pacman.d/hooks/hyprland-plugins.hook
   ```
   Replace `<YOURNAME>` with your actual username in both locations.

### How It Works

- **Trigger:** Activates when `hyprland` or `hyprland-git` packages are upgraded
- **Action:** Runs `hyprpm update` as your user after the transaction completes
- **Notification:** Sends a desktop notification when the rebuild starts

### Requirements

- `hyprland` or `hyprland-git` installed
- `hyprpm` available in PATH
- `libnotify` (for notifications via `notify-send`)
- Sudo privileges for the pacman hook system

### Troubleshooting

If plugins fail to rebuild:

1. Check the hook is installed:
   ```bash
   ls -l /etc/pacman.d/hooks/hyprland-plugins.hook
   ```

2. Verify the script is executable:
   ```bash
   ls -l ~/.config/update-hyprpm.sh
   ```

3. Manually test the script:
   ```bash
   ~/.config/update-hyprpm.sh
   ```

4. Check pacman hook logs:
   ```bash
   journalctl -b | grep hyprpm
   ```

### Related Files

- [update-hyprpm.sh](../scripts/update-hyprpm.sh) - The script executed by the hook
- [hypr/](../hypr/) - Hyprland configuration files
