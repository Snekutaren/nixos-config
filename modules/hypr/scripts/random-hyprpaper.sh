#!/usr/bin/env bash

# Directories for main and secondary wallpapers
MAIN_DIR="$HOME/Pictures/Wallpapers/Main"
SECONDARY_DIR="$HOME/Pictures/Wallpapers/Secondary"

# Pick random wallpapers
MAIN_WP=$(find "$MAIN_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)
SECONDARY_WP=$(find "$SECONDARY_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

# Preload both
hyprctl hyprpaper preload "$MAIN_WP"
PRELOAD_MAIN=$?

hyprctl hyprpaper preload "$SECONDARY_WP"
PRELOAD_SECONDARY=$?

# Only set wallpaper if preload was successful
if [[ $PRELOAD_MAIN -eq 0 ]]; then
    hyprctl hyprpaper wallpaper "DP-1,$MAIN_WP"
else
    echo "[ERROR] Failed to preload $MAIN_WP"
fi

if [[ $PRELOAD_SECONDARY -eq 0 ]]; then
    hyprctl hyprpaper wallpaper "DP-2,$SECONDARY_WP"
else
    echo "[ERROR] Failed to preload $SECONDARY_WP"
fi
