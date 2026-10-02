#!/usr/bin/env bash
# wf-recorder stand-in: toggle a full-desktop recording with ffmpeg.
if pkill -INT -f 'ffmpeg .*x11grab'; then
    notify-send "Recording saved" 2>/dev/null
    exit 0
fi
mkdir -p ~/Videos/Recordings
size=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ {print $2}')
notify-send "Recording started" 2>/dev/null
exec ffmpeg -y -f x11grab -framerate 60 ${size:+-video_size "$size"} -i "$DISPLAY" \
    -c:v libx264 -preset ultrafast -pix_fmt yuv420p \
    ~/Videos/Recordings/"$(date '+%Y-%m-%d_%H.%M.%S')".mp4
