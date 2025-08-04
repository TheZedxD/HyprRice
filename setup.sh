#!/usr/bin/env bash
# setup.sh: umbrella script to install HyprRice environment
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; RESET="\e[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$HOME/HyprRice"
LOG_FILE="$LOG_DIR/setup.log"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

run_step() {
    local desc="$1" script="$2"
    echo -ne "==> $desc... "
    set +e
    "$SCRIPT_DIR/$script"
    local status=$?
    set -e
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}OK${RESET}"
    else
        echo -e "${RED}ERROR${RESET}"
        exit $status
    fi
}

run_step "Install packages" install.sh
run_step "Apply login theme" fix_login_theme.sh
run_step "Configure audio" fix_sound.sh
run_step "Install TV app" install_tv.sh
run_step "Run validation" validate.sh

echo -e "\nSetup complete. Log saved to $LOG_FILE"
