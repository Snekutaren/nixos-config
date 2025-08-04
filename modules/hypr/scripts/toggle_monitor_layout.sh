#!/bin/bash

# Monitor names
MON_LEFT="DP-2"   # AOC AG271QG4
MON_RIGHT="DP-1"  # Samsung Odyssey G70B

# Positions
POS_LEFT="0x0"
POS_RIGHT_CONNECTED="2560x0"
POS_RIGHT_ISOLATED="10000x0"

# Modes
RES_LEFT="2560x1440@144"
RES_RIGHT="3840x2160@144"

# Get current X position of right monitor (DP-1)
POS_RIGHT_CURRENT_X=$(hyprctl monitors -j | jq -r '.[] | select(.name=="'"$MON_RIGHT"'") | .x')

if [[ "$POS_RIGHT_CURRENT_X" == "2560" ]]; then
  MODE="CONNECTED"
elif [[ "$POS_RIGHT_CURRENT_X" == "10000" ]]; then
  MODE="ISOLATED"
else
  MODE="UNKNOWN"
fi

case $MODE in
  "CONNECTED")
    echo "→ Switching to ISOLATED layout..."
    hyprctl keyword monitor "$MON_LEFT,$RES_LEFT,$POS_LEFT,1,vrr,2"
    hyprctl keyword monitor "$MON_RIGHT,$RES_RIGHT,$POS_RIGHT_ISOLATED,1"

    # Set right monitor border red with size 3 (isolated)
    hyprctl dispatch monitorrule "$MON_RIGHT" "border_size=3 border_color=0xffff4444"
    # Remove left monitor border
    hyprctl dispatch monitorrule "$MON_LEFT" "border_size=0"

    #notify-send "Hyprland Monitor Layout" "Switched to ISOLATED layout\nRight monitor border: Red"
    ;;

  "ISOLATED")
    echo "→ Switching to CONNECTED layout..."
    hyprctl keyword monitor "$MON_LEFT,$RES_LEFT,$POS_LEFT,1,vrr,2"
    hyprctl keyword monitor "$MON_RIGHT,$RES_RIGHT,$POS_RIGHT_CONNECTED,1"

    # Reset borders on both monitors
    hyprctl dispatch monitorrule "$MON_RIGHT" "border_size=0"
    hyprctl dispatch monitorrule "$MON_LEFT" "border_size=0"

    #notify-send "Hyprland Monitor Layout" "Switched to CONNECTED layout\nBorders reset"
    ;;

  *)
    echo "⚠️ Unknown monitor position ($POS_RIGHT_CURRENT_X). No changes made."
    #notify-send "Hyprland Monitor Layout" "Unknown mode: $POS_RIGHT_CURRENT_X\nNo changes applied."
    ;;
esac
