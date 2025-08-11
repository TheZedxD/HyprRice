#!/usr/bin/env bash
set -euo pipefail
CHEAT="$HOME/.config/hypr/shortcuts.txt"
[ -f "$CHEAT" ] || cat > "$CHEAT" <<'TXT'
HyprRice — Super shortcuts (default)
  Super+Enter      Terminal (Alacritty)
  Super+Space      Wofi launcher
  Super+E / B      Thunar / Firefox
  Super+L          Lock (swaylock)
  Super+M          Power menu (wlogout)
  Super+Q / W      Close / Force close
  Super+F          Fullscreen
  Super+V / J      Toggle floating / Toggle split
  Super+Arrows     Focus window
  Super+Shift+Arrows Move window
  Super+Ctrl+Arrows  Send window to workspace
  Super+1..9 / Shift+1..9  Switch / Move to workspace
  Super+Tab / Shift+Tab    Next / Prev workspace
  Alt+Tab / Shift+Tab      Cycle windows
  Print / Super+S          Screenshot full / region
TXT
# open in a terminal with less (fallback order)
for term in alacritty foot kitty xterm; do
  if command -v "$term" >/dev/null 2>&1; then exec "$term" -e bash -lc "less -R \"$CHEAT\""; fi
done
# if no terminal found, try wofi preview as a fallback
wofi --dmenu < "$CHEAT"
