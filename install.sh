#!/usr/bin/env bash
# Simple installer for HyprRice dotfiles.
# Copies configuration files into the current user's ~/.config directory.
# If run with sudo, files will be placed in the invoking user's home.
set -euo pipefail

TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"

printf 'Installing configuration for user %s in %s\n' "$TARGET_USER" "$CONFIG_DEST"

# Ensure required packages are installed
needed=(alacritty hyprland waybar wofi swaybg dolphin firefox pavucontrol networkmanager)
missing=()
for cmd in "${needed[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done
if ((${#missing[@]})); then
    if command -v pacman >/dev/null 2>&1; then
        printf 'Installing missing dependencies: %s\n' "${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    else
        printf 'Warning: missing dependencies: %s\n' "${missing[*]}"
    fi
fi

DIRS=(alacritty hypr waybar wofi)

progress() {
    local current=$1 total=$2 width=30
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local bar
    bar=$(printf "%${filled}s" | tr ' ' '#')
    printf '\r[%-*s] %d%%' "$width" "$bar" "$percent"
}

mkdir -p "$CONFIG_DEST"
total=${#DIRS[@]}
step=0
progress $step $total
for dir in "${DIRS[@]}"; do
    rm -rf "$CONFIG_DEST/$dir"
    cp -r ".config/$dir" "$CONFIG_DEST/"
    step=$((step+1))
    progress $step $total
    printf '\nInstalled %s configuration.\n' "$dir"
done

echo -e '\nHyprRice installation complete.'
