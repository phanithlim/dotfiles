#!/bin/bash

# ─── [ Header Generator Tool ] ───────────────────────────

function gen-header() {
    local title="$1"
    local width=60
    local title_len=${#title}
    
    # Calculate padding
    local total_padding=$(( width - title_len ))
    local pad_left=$(( total_padding / 2 ))
    local pad_right=$(( total_padding - pad_left ))
    
    echo "# ┌$(printf '─%.0s' $(seq 1 $width))┐"
    echo -n "# │"
    printf "%${pad_left}s" ""
    echo -n "$title"
    printf "%${pad_right}s" ""
    echo "│"
    echo "# └$(printf '─%.0s' $(seq 1 $width))┘"
}

function gen-line() {
    local title="$1"
    local total_width=62 # Matches the box width
    local prefix="# ─── [ $title ] "
    local prefix_len=${#prefix}
    local line_len=$(( total_width - prefix_len ))
    
    if [ $line_len -lt 0 ]; then line_len=0; fi
    
    echo -n "$prefix"
    printf '─%.0s' $(seq 1 $line_len)
    echo ""
}

# ─── [ Execution Logic ] ────────────────────────────────

# ─── [ Execution Logic ] ────────────────────────────────

case "$1" in
    "line")
        # Only run if a title is actually provided
        [[ -n "$2" ]] && gen-line "$2"
        ;;
    "")
        # Do nothing if no arguments are passed (prevents message on terminal start)
        :
        ;;
    *)
        # Default to boxed header for any other input
        gen-header "$1"
        ;;
esac
