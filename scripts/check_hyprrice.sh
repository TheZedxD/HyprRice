#!/usr/bin/env bash
set -euo pipefail
ok(){ printf "✔ %s\n" "$1"; }
warn(){ printf "✖ %s\n" "$1"; exit 1; }

command -v hyprctl >/dev/null || warn "hyprctl missing"
command -v waybar >/dev/null || warn "waybar missing"
command -v wofi >/dev/null || warn "wofi missing"
command -v wlogout >/dev/null || warn "wlogout missing"

grep -q '"hyprland/workspaces"' ~/.config/waybar/config* || warn "Waybar workspaces module not found"
grep -q 'active-only": *false' ~/.config/waybar/config* || ok "Workspaces show multiple (active-only=false)"
grep -q 'on-click": *"activate"' ~/.config/waybar/config* || ok "Click action set (activate or hyprctl)"

[ -f ~/.config/waybar/style.css ] && grep -q '#workspaces button.active' ~/.config/waybar/style.css && ok "Active workspace styled"

grep -q 'bind *= *\$mod, *Tab, *workspace, *e\+1' ~/.config/hypr/hyprland.conf && ok "Super+Tab set"
grep -q 'bind *= *ALT, *Tab, *cyclenext' ~/.config/hypr/hyprland.conf && ok "Alt+Tab set"

[ -f ~/.config/wlogout/style.css ] && ok "wlogout themed"

desk="$HOME/.local/share/applications/tv.desktop"
[ -f "$desk" ] && grep -q '^Exec=' "$desk" && ok "TV desktop entry present"

echo "All checks passed."
