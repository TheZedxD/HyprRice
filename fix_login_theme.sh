#!/usr/bin/env bash
# fix_login_theme.sh: apply neon green greetd/tuigreet theme
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; RESET="\e[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG_SRC="$SCRIPT_DIR/greetd/config.toml"
CFG_DST="/etc/greetd/config.toml"

if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

install -Dm644 "$CFG_SRC" "$CFG_DST"

echo -e "${GREEN}Greetd configuration installed at $CFG_DST${RESET}"

if command -v systemctl >/dev/null 2>&1; then
    DM_SERVICES=(gdm.service sddm.service lightdm.service lxdm.service ly.service)
    for svc in "${DM_SERVICES[@]}"; do
        systemctl disable --now "$svc" >/dev/null 2>&1 || true
    done
    if systemctl list-unit-files | grep -q '^greetd.service'; then
        systemctl enable --now greetd.service || true
        echo -e "${GREEN}greetd enabled${RESET}"
    else
        echo -e "${YELLOW}greetd service not found; skipping enable.${RESET}"
    fi
else
    echo -e "${YELLOW}systemctl not found; enable greetd manually.${RESET}"
fi
