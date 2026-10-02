#!/usr/bin/env bash
# Caps Lock <-> Escape swap (for Vim). "toggle" flips it, no arg restores the last state.
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/i3-capsswap"

state="$(cat "$STATE" 2>/dev/null || echo on)"
if [[ $1 == toggle ]]; then
    [[ $state == on ]] && state=off || state=on
fi

# Keep any other keyboard options, only add/remove caps:swapescape
others="$(setxkbmap -query | sed -n 's/^options:\s*//p' | tr ',' '\n' | grep -vx 'caps:swapescape' | paste -sd,)"
opts="$others"
[[ $state == on ]] && opts="${others:+$others,}caps:swapescape"
setxkbmap -option "" ${opts:+-option "$opts"}

mkdir -p "$(dirname "$STATE")"
echo "$state" > "$STATE"
if [[ $1 == toggle ]]; then
    # The keybind's own Caps press toggles Caps Lock on; undo that
    sleep 0.1
    if grep -qx 1 /sys/class/leds/*::capslock/brightness 2>/dev/null; then
        xdotool key Caps_Lock
    fi
    # Background + timeout: notify-send blocks if no notification daemon answers
    (timeout 2 notify-send -t 1500 "Caps/Escape swap" "$state" 2>/dev/null &)
fi
exit 0
