#!/bin/bash

# Start swww if not already running
pgrep -x swww-daemon >/dev/null || swww init

# Wait briefly to ensure swww is ready
sleep 1

# Define wallpaper folders
MAIN_DIR="$HOME/Pictures/Wallpapers/Main"
SECOND_DIR="$HOME/Pictures/Wallpapers/Second"

# Get monitor names in order
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))

# Sanity check
if [ "${#MONITORS[@]}" -lt 2 ]; then
    echo "Expected at least 2 monitors. Found ${#MONITORS[@]}." >&2
    exit 1
fi

# Pick a random image from each folder
MAIN_WP=$(find "$MAIN_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)
SECOND_WP=$(find "$SECOND_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)

# Set the wallpapers
swww img "$MAIN_WP" --output "${MONITORS[0]}"
swww img "$SECOND_WP" --output "${MONITORS[1]}"
