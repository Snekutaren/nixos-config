#!/bin/bash

LOGFILE="$HOME/.local/share/hyprlock-dpms-debug.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOGFILE"
    # Optionally also log to system journal
    # logger "[hyprlock-dpms] $*"
}

log "=== Script started ==="
HYPRLOCK_PID=$(pidof hyprlock)
if [ -z "$HYPRLOCK_PID" ]; then
    log "hyprlock is not running, starting it..."
    hyprlock &
    HYPRLOCK_PID=$!
    log "Started hyprlock with PID $HYPRLOCK_PID"
else
    log "hyprlock already running with PID $HYPRLOCK_PID"
fi

sleep 2

(
    log "Monitor loop started (PID $$)"
    while pidof hyprlock > /dev/null; do
        log "hyprlock is still running, sleeping for 60 seconds..."
        sleep 60

        if pidof hyprlock > /dev/null; then
            log "Checking DPMS status..."
            RAW_OUTPUT=$(hyprctl monitors)
            log "hyprctl monitors output:\n$RAW_OUTPUT"

            DPMS_STATUS=$(echo "$RAW_OUTPUT" | grep dpmsStatus | head -n 1 | awk '{print $2}')
            log "Parsed dpmsStatus: '$DPMS_STATUS'"

            if [ "$DPMS_STATUS" = "1" ]; then
                log "DPMS is currently ON. Dispatching command to turn it OFF..."
                sleep 0.5
                #hyprctl dispatch dpms off DP-1 && 
                log "Successfully turned off DPMS" || log "Failed to turn off DPMS"
            else
                log "DPMS is already OFF, nothing to do."
            fi
        else
            log "hyprlock exited between checks, exiting loop."
            break
        fi
    done
    log "Monitor loop ended."
) &

log "=== Script finished setup phase ==="
