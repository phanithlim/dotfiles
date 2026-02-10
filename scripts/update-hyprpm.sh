#!/bin/bash
# Send a notification so you know the hook triggered
notify-send "Hyprland Update" "Rebuilding plugins via hyprpm..."

# Run the update
/usr/bin/hyprpm update
