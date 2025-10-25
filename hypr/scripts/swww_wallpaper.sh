#!/bin/bash

# CONFIG
WALLPAPER_DIR="$HOME/.config/assets/backgrounds"
STATE_FILE="$HOME/.config/hypr/.current_wallpaper_index"  # Persistent location
TRANSITION_ARGS="--transition-fps 120 --transition-type outer --transition-duration 0.8"
DIRECTION="$1"  # "next" or "prev"

# Debugging output
echo "WALLPAPER_DIR: $WALLPAPER_DIR"
echo "DIRECTION: $DIRECTION"
echo "STATE_FILE: $STATE_FILE"

# Ensure WALLPAPER_DIR exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    notify-send "Wallpaper directory $WALLPAPER_DIR does not exist"
    exit 1
fi

# Read wallpapers into array
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

# Fallback if no wallpapers found
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    notify-send "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Load last index or start at 0
if [ -f "$STATE_FILE" ]; then
    index=$(<"$STATE_FILE")
    # Validate index
    if ! [[ "$index" =~ ^[0-9]+$ ]] || [ "$index" -ge "${#wallpapers[@]}" ]; then
        index=0
    fi
else
    index=0
fi

# Debugging output
echo "Current wallpaper index: $index"

# Determine new index
if [[ "$DIRECTION" == "next" ]]; then
    index=$(( (index + 1) % ${#wallpapers[@]} ))
elif [[ "$DIRECTION" == "prev" ]]; then
    index=$(( (index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
elif [[ -z "$DIRECTION" ]]; then
    # If no direction provided, keep current index (for startup)
    index=$index
else
    echo "Invalid direction: $DIRECTION"
    exit 1
fi

# Save the new index
echo "$index" > "$STATE_FILE"

# Debugging output
echo "New wallpaper index: $index"

# Set wallpaper
echo "Setting wallpaper: ${wallpapers[$index]}"
swww img "${wallpapers[$index]}" $TRANSITION_ARGS

# Check if swww ran successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to change wallpaper"
    notify-send "Error: Failed to change wallpaper"
    exit 1
fi