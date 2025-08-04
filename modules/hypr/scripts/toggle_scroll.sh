#!/bin/bash

# Use 'which hyprctl' to get the full path to hyprctl on NixOS
HYPRCTL_PATH="$(which hyprctl)"

# Get the current scroll factor value
# This command now correctly extracts the value from the 'float: 10.000000' output.
current_factor=$("$HYPRCTL_PATH" getoption input:scroll_factor | head -n 1 | awk '{print $2}')

# Check if the current factor is "high" using numeric comparison
# We use 'bc' for reliable floating-point comparison.
if (( $(echo "$current_factor > 5.0" | bc -l) )); then
    "$HYPRCTL_PATH" keyword input:scroll_factor 2.5
else
    "$HYPRCTL_PATH" keyword input:scroll_factor 8.0
fi
