#!/usr/bin/env bash
# setup.sh: Orchestrate full HyprRice installation with logging
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting HyprRice setup..."

run_step() {
    local desc="$1"; local script="$2"
    if [[ -x "$SCRIPT_DIR/$script" ]]; then
        echo -e "\n==> $desc"
        "$SCRIPT_DIR/$script"
    else
        echo -e "\nSkipping $desc (missing $script)"
    fi
}

# Ensure python command is available and venv module works
if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    echo "Creating python symlink to python3..."
    sudo ln -sf "$(command -v python3)" /usr/bin/python
fi

if command -v python >/dev/null 2>&1; then
    if python -m venv "$SCRIPT_DIR/.venv-test" >/dev/null 2>&1; then
        rm -rf "$SCRIPT_DIR/.venv-test"
    elif command -v pacman >/dev/null 2>&1; then
        echo "Installing python-virtualenv for venv support..."
        sudo pacman -S --needed --noconfirm python-virtualenv || true
    fi
fi

run_step "Install base configuration" install.sh
run_step "Apply login screen theme" fix_login_theme.sh
run_step "Apply sound fix" fix_sound.sh
run_step "Update configuration" update.sh
run_step "Run system check" system_check.sh
run_step "Install optional TV application" install_tv.sh

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

echo -e "\nHyprRice setup complete. Logs saved to $LOG_FILE"
