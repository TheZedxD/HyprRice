#!/usr/bin/env bash
# PC_Setup.sh: Unified setup script for HyprRice and optional components
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running HyprRice install script..."
bash "$SCRIPT_DIR/install.sh"

echo "Applying login screen theme..."
bash "$SCRIPT_DIR/fix_login_theme.sh"

echo "Applying sound fix..."
bash "$SCRIPT_DIR/fix_sound.sh"

echo "Updating configuration..."
bash "$SCRIPT_DIR/update.sh"

echo "Running system check..."
bash "$SCRIPT_DIR/system_check.sh"

echo "Installing TV application..."
bash "$SCRIPT_DIR/install_tv.sh"

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

echo "Setup complete! You can now reboot and log in to Hyprland. Enjoy."

