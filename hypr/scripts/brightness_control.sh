#!/usr/bin/env bash
# File: ~/scripts/brightness_notify.sh

# Get current brightness in %
get_brightness() {
    brightnessctl g
}

# Get max brightness
get_max() {
    brightnessctl m
}

# Send the notification via Dunst
send_notification() {
    icon="preferences-system-brightness"
    current=$(get_brightness)
    max=$(get_max)
    percent=$(( current * 100 / max ))

    # Make a visual bar (each ─ = 5%)
    bar=$(seq -s "─" 0 $((percent / 5)) | sed 's/[0-9]//g')

    dunstify -i "$icon" -r 5555 -u normal "$bar $percent%"
}

case $1 in
    up)
        brightnessctl s +5% >/dev/null
        send_notification
        ;;
    down)
        brightnessctl s 5%- >/dev/null
        send_notification
        ;;
    *)
        send_notification
        ;;
esac
