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
packages=(
    alacritty
    archlinux-xdg-menu
    desktop-file-utils
    bluez
    bluez-utils
    blueman
    brightnessctl
    firefox
    grim
    gvfs
    gsimplecal
    htop
    hyprland
    jq
    ncdu
    networkmanager
    network-manager-applet
    nm-connection-editor
    nwg-look
    pamixer
    pavucontrol
    polkit-gnome
    power-profiles-daemon
    slurp
    swaybg
    swayidle
    swaylock
    swaync
    thunar
    ttf-font-awesome
    ttf-jetbrains-mono-nerd
    waybar
    wlogout
    wofi
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xfce4-power-manager
    xfce4-settings
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
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" update-desktop-database || true
fi
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now NetworkManager.service || true
    sudo systemctl enable --now bluetooth.service || true
    sudo systemctl enable --now power-profiles-daemon.service || true
    sudo -u "$TARGET_USER" systemctl --user restart xdg-desktop-portal-hyprland.service || true
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

echo 'Please log out or reboot to start a Hyprland session.'
