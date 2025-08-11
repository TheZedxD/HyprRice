#!/usr/bin/env bash
set -euo pipefail
echo "HyprRice — available commands"
echo
printf " %-22s %s\n" "install.sh"       "Install packages and base config"
printf " %-22s %s\n" "setup.sh"         "Umbrella setup (fixes, optional TV app, etc.)"
printf " %-22s %s\n" "update.sh"        "Sync configs, refresh menus, reload Hyprland/Waybar"
printf " %-22s %s\n" "system_check.sh"  "Diagnostics: graphics/audio/services"
printf " %-22s %s\n" "validate.sh"      "Lint/syntax/style sanity checks"
echo
echo "Versions:"
for c in hyprland hyprctl waybar wofi wlogout swaybg swayidle swaylock alacritty thunar firefox nm-connection-editor blueman pulsemixer ffmpeg yt-dlp python; do
  if command -v "$c" >/dev/null 2>&1; then printf "  %-22s %s\n" "$c" "$($c --version 2>/dev/null | head -n1)"; else printf "  %-22s %s\n" "$c" "MISSING"; fi
done
