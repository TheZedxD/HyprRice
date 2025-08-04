#!/usr/bin/env bash
# Script to fix greetd login screen theme
set -euo pipefail

RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; RESET='\e[0m'

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root.${RESET}"
    exit 1
fi

PKGS=(greetd greetd-tuigreet)
if command -v pacman >/dev/null 2>&1; then
    missing=()
    for pkg in "${PKGS[@]}"; do
        pacman -Qi "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    if ((${#missing[@]})); then
        echo -e "Installing missing packages: ${missing[*]}"
        pacman -S --needed --noconfirm "${missing[@]}" || true
    fi
else
    echo -e "${YELLOW}pacman not found; skipping package installation.${RESET}"
fi

CFG_DIR=/etc/greetd
CFG_FILE=$CFG_DIR/config.toml
mkdir -p "$CFG_DIR"

cat > "$CFG_FILE" <<'EOC'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --user-menu --cmd Hyprland --theme 'text=green;prompt=green;input=green;container=black;border=green;title=green;action=green;button=green'"
user = "greeter"
EOC

if command -v systemctl >/dev/null 2>&1; then
    DM_SERVICES=(gdm.service sddm.service lightdm.service lxdm.service ly.service)
    for svc in "${DM_SERVICES[@]}"; do
        systemctl disable --now "$svc" >/dev/null 2>&1 || true
    done
    systemctl enable --now greetd.service || true
else
    echo -e "${YELLOW}systemctl not found; cannot manage display managers.${RESET}"
fi

echo -e "${GREEN}Login screen theme applied. Reboot to see changes.${RESET}"
