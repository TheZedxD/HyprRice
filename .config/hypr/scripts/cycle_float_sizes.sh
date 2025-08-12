#!/usr/bin/env bash
# Cycle floating window through preset sizes
set -euo pipefail
active=$(hyprctl -j activewindow 2>/dev/null)
[ -z "$active" ] && exit 0
mon=$(echo "$active" | jq -r '.monitor')
minfo=$(hyprctl -j monitors | jq -r ".[] | select(.name==\"$mon\")")
width=$(echo "$minfo" | jq '.width')
height=$(echo "$minfo" | jq '.height')
smallw=$((width / 2))
smallh=$((height / 2))
medw=$((width * 3 / 4))
medh=$((height * 3 / 4))
fullw=$width
fullh=$height
floating=$(echo "$active" | jq -r '.floating')
if [ "$floating" = "false" ]; then
  hyprctl dispatch togglefloating
  hyprctl dispatch resizeactive exact "$smallw" "$smallh"
  hyprctl dispatch centerwindow
  exit 0
fi
curw=$(echo "$active" | jq '.size[0]')
if [ "$curw" -le $((smallw + 5)) ]; then
  hyprctl dispatch resizeactive exact "$medw" "$medh"
elif [ "$curw" -le $((medw + 5)) ]; then
  hyprctl dispatch resizeactive exact "$fullw" "$fullh"
else
  hyprctl dispatch resizeactive exact "$smallw" "$smallh"
fi
hyprctl dispatch centerwindow
