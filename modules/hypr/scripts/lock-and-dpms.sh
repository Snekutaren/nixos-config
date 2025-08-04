#!/bin/bash
        pidof hyprlock || hyprlock &
        sleep 2
        (
            while pidof hyprlock > /dev/null; do
                sleep 60
                if pidof hyprlock > /dev/null; then
                    DPMS_STATUS=$(hyprctl monitors | grep dpmsStatus | head -n 1 | awk '{print $2}')
                    if [ "$DPMS_STATUS" = "1" ]; then
                        sleep 0.5 && hyprctl dispatch dpms off
                    fi
                else
                    break
                fi
            done
        ) &