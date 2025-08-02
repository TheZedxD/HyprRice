#!/usr/bin/env bash
# Simple installer for HyprRice dotfiles.
# Copies configuration files into the current user's ~/.config directory.
# If run with sudo, files will be placed in the invoking user's home.
set -euo pipefail

TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"

printf 'Installing configuration for user %s in %s\n' "$TARGET_USER" "$CONFIG_DEST"

# Check for common dependencies and warn if missing
needed=(alacritty hyprland waybar wofi swaybg)
missing=()
for cmd in "${needed[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done
if ((${#missing[@]})); then
    printf 'Warning: missing dependencies: %s\n' "${missing[*]}"
fi

mkdir -p "$CONFIG_DEST"
for dir in alacritty hypr waybar wofi; do
    mkdir -p "$CONFIG_DEST/$dir"
    cp -r ".config/$dir/." "$CONFIG_DEST/$dir/"
    printf 'Installed %s configuration.\n' "$dir"
done

echo 'HyprRice installation complete.'
