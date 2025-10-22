#!/usr/bin/env bash

# Get the focused window info
wininfo=$(hyprctl -j activewindow)
if [ -z "$wininfo" ]; then
  exit 0
fi

# Get screen width (monitor width)
monitor_info=$(hyprctl -j monitors | jq '.[] | select(.focused==true)')
screen_width=$(echo "$monitor_info" | jq '.width')

# Get window geometry
win_x=$(echo "$wininfo" | jq '.at[0]')
win_width=$(echo "$wininfo" | jq '.size[0]')

# Calculate window center
win_center=$((win_x + win_width / 2))
half_screen=$((screen_width / 2))

# Decide direction based on position
if [ "$win_center" -gt "$half_screen" ]; then
  # Window is on the right side → swap left
  hyprctl dispatch swapwindow l
else
  # Window is on the left side → swap right
  hyprctl dispatch swapwindow r
fi
