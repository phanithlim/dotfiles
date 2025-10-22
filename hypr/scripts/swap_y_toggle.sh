#!/usr/bin/env bash

wininfo=$(hyprctl -j activewindow)
if [ -z "$wininfo" ]; then
  exit 0
fi

monitor_info=$(hyprctl -j monitors | jq '.[] | select(.focused==true)')
screen_height=$(echo "$monitor_info" | jq '.height')

win_y=$(echo "$wininfo" | jq '.at[1]')
win_height=$(echo "$wininfo" | jq '.size[1]')

win_center=$((win_y + win_height / 2))
half_screen=$((screen_height / 2))

if [ "$win_center" -gt "$half_screen" ]; then
  hyprctl dispatch swapwindow u
else
  hyprctl dispatch swapwindow d
fi
