#!/usr/bin/env bash
# Toggle centered floating zoomed window
set -euo pipefail
active=$(hyprctl -j activewindow 2>/dev/null)
[ -z "$active" ] && exit 0
floating=$(echo "$active" | jq -r '.floating')
if [ "$floating" = "false" ]; then
    mon=$(echo "$active" | jq -r '.monitor')
    minfo=$(hyprctl -j monitors | jq -r ".[] | select(.name==\"$mon\")")
    width=$(echo "$minfo" | jq '.width')
    height=$(echo "$minfo" | jq '.height')
    neww=$((width * 8 / 10))
    newh=$((height * 8 / 10))
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact "$neww" "$newh"
    hyprctl dispatch centerwindow
else
    hyprctl dispatch togglefloating
fi
