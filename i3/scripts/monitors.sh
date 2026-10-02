#!/usr/bin/env bash
# Monitor layouts: aoc (DP-0 only), lg (DP-2 only), both. No arg = restore last.
AOC=DP-0
LG=DP-2
# Max refresh rates (see: xrandr --query)
AOC_MODE=(--mode 1920x1080 --rate 300)
LG_MODE=(--mode 3440x1440 --rate 160)
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/i3-monitors"

mode="${1:-$(cat "$STATE" 2>/dev/null || echo aoc)}"

# Never switch to a layout that needs the LG while it's unplugged (would leave no screen / a ghost output)
if [[ $mode != aoc ]] && ! xrandr --query | grep -q "^$LG connected"; then
    notify-send "Monitors" "LG not connected, using AOC only" 2>/dev/null
    mode=aoc
fi

case "$mode" in
    aoc)  xrandr --output "$AOC" "${AOC_MODE[@]}" --primary --pos 0x0 --output "$LG" --off ;;
    lg)   xrandr --output "$LG" "${LG_MODE[@]}" --primary --pos 0x0 --output "$AOC" --off ;;
    both) xrandr --output "$LG" "${LG_MODE[@]}" --pos 0x0 \
                 --output "$AOC" "${AOC_MODE[@]}" --primary --right-of "$LG" ;;
    *)    echo "usage: $0 [aoc|lg|both]" >&2; exit 1 ;;
esac || { notify-send "Monitors" "Switching to '$mode' failed" 2>/dev/null; exit 1; }

mkdir -p "$(dirname "$STATE")"
echo "$mode" > "$STATE"
# Redraw the wallpaper for the new screen size
feh --no-fehbg --bg-fill ~/.config/hypr/wallpaper.jpeg
