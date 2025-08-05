#!/usr/bin/env bash
# run_all.sh: execute all setup scripts with logging
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$HOME/HyprRice"
LOG_FILE="$LOG_DIR/run_all.log"
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
        echo "OK"
    else
        echo "FAIL"
        exit $status
    fi
}

run_step "Install packages" install.sh
run_step "Apply login theme" fix_login_theme.sh
run_step "Configure audio" fix_sound.sh
run_step "Install TV app" install_tv.sh
run_step "Update configs" update.sh
run_step "Run syntax tests" tests/test_syntax.sh
run_step "Run validation" validate.sh
run_step "Run system check" system_check.sh

echo "Everything installed correctly"
