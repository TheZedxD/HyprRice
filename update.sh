#!/usr/bin/env bash
# Simple updater for HyprRice dotfiles.
# Pulls latest git changes and re-installs configuration.
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER:-$(id -un)}}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
DIRS=(alacritty hypr waybar wofi)

# Ensure required packages are installed
packages=(
    alacritty
    hyprland
    waybar
    wofi
    swaybg
    dolphin
    firefox
    pavucontrol
    networkmanager
    network-manager-applet
    nm-connection-editor
    xfce4-power-manager-settings
    htop
    ncdu
    jq
    archlinux-xdg-menu
    desktop-file-utils
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    polkit-gnome
)
if command -v pacman >/dev/null 2>&1; then
    missing=()
    for pkg in "${packages[@]}"; do
        pacman -Qi "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    if ((${#missing[@]})); then
        printf 'Installing missing dependencies: %s\n' "${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
else
    printf 'Warning: pacman not found; cannot verify dependencies.\n'
fi

# Rebuild application menus and ensure portals/services are running
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" XDG_MENU_PREFIX=arch- kbuildsycoca6 || true
fi
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now NetworkManager.service || true
    sudo -u "$TARGET_USER" systemctl --user restart xdg-desktop-portal-hyprland.service || true
fi

progress() {
    local current=$1 total=$2 width=30
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local bar
    bar=$(printf "%${filled}s" | tr ' ' '#')
    printf '\r[%-*s] %d%%' "$width" "$bar" "$percent"
}

total=$(( ${#DIRS[@]} + 1 ))
step=0

echo "Updating HyprRice for ${TARGET_USER}"
progress $step $total

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "\nFetching latest changes..."
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
    git fetch origin "$current_branch"
    git reset --hard "origin/$current_branch"
else
    echo -e "\nNot a git repository; skipping update."
fi
step=$((step+1))
progress $step $total

mkdir -p "$CONFIG_DEST"
for dir in "${DIRS[@]}"; do
    echo -e "\nSyncing $dir configuration..."
    rm -rf "$CONFIG_DEST/$dir"
    cp -r ".config/$dir" "$CONFIG_DEST/"
    step=$((step+1))
    progress $step $total
done

echo -e "\nHyprRice update complete."
