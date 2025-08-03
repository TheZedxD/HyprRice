#!/usr/bin/env bash
# Basic OS health check for HyprRice on Arch Linux
set -euo pipefail

RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; RESET='\e[0m'
errors=0

check_cmd() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${RESET} command '$cmd' found"
    else
        echo -e "${RED}[MISSING]${RESET} command '$cmd' not found"
        errors=$((errors+1))
    fi
}

check_service() {
    local svc="$1"
    if systemctl is-active --quiet "$svc"; then
        echo -e "${GREEN}[OK]${RESET} service '$svc' active"
    else
        echo -e "${RED}[FAIL]${RESET} service '$svc' inactive"
        errors=$((errors+1))
    fi
}

echo "Checking graphics stack..."
check_cmd glxinfo && glxinfo | grep -E 'OpenGL renderer|OpenGL version' || true

echo "Checking audio stack..."
check_cmd pactl && pactl info >/dev/null 2>&1 || errors=$((errors+1))
check_service pipewire
check_service wireplumber

echo "Checking core commands..."
for cmd in hyprland hyprctl waybar wofi swaybg swayidle swaylock alacritty firefox; do
    check_cmd "$cmd"
fi

echo "Checking system services..."
for svc in NetworkManager bluetooth power-profiles-daemon; do
    check_service "$svc"
done

echo "Checking compositor runtime..."
if command -v hyprctl >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    hyprctl monitors >/dev/null 2>&1 && echo -e "${GREEN}[OK]${RESET} Hyprland running" || {
        echo -e "${RED}[FAIL]${RESET} Hyprland not responding"; errors=$((errors+1)); }
else
    echo -e "${YELLOW}[WARN]${RESET} Hyprland environment not detected"
fi

if ((errors)); then
    echo -e "${RED}System checks found issues.${RESET}"
    exit 1
else
    echo -e "${GREEN}All system checks passed.${RESET}"
fi
