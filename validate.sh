#!/usr/bin/env bash
# validate.sh: run basic sanity checks
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; RESET="\e[0m"
errors=0

check() {
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo -e "$desc: ${GREEN}OK${RESET}"
    else
        echo -e "$desc: ${RED}ERROR${RESET}"
        errors=$((errors+1))
    fi
}

check "hyprctl" command -v hyprctl

if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-system-running >/dev/null 2>&1; then
        if systemctl --failed --no-legend | grep . >/dev/null 2>&1; then
            echo -e "Failed systemd units present: ${RED}ERROR${RESET}"
            errors=$((errors+1))
        else
            echo -e "systemctl --failed: ${GREEN}OK${RESET}"
        fi
        check "greetd active" systemctl is-active greetd.service
    else
        echo -e "systemd not running: ${YELLOW}skipping system checks${RESET}"
    fi
else
    echo -e "systemctl: ${YELLOW}not found${RESET}"
fi

if command -v pactl >/dev/null 2>&1; then
    module=$(pactl load-module module-null-sink 2>/dev/null || true)
    if [[ -n "$module" ]]; then
        pactl unload-module "$module"
        echo -e "audio loop-back: ${GREEN}OK${RESET}"
    else
        echo -e "audio loop-back: ${RED}ERROR${RESET}"
        errors=$((errors+1))
    fi
else
    echo -e "pactl: ${YELLOW}not found${RESET}"
fi

if ((errors>0)); then
    echo -e "${YELLOW}Validation completed with warnings${RESET}"
else
    echo -e "${GREEN}All checks passed${RESET}"
fi
