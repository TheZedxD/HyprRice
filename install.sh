#!/usr/bin/env bash
# install.sh: install packages and deploy configs
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; RESET="\e[0m"

if ! command -v pacman >/dev/null 2>&1; then
    echo -e "${RED}pacman not found. Aborting.${RESET}"
    exit 1
fi

PACMAN_PKGS=(
    alacritty firefox thunar wofi waybar wlogout
    hyprland greetd pipewire pipewire-pulse pipewire-alsa wireplumber
    alsa-utils pulsemixer grim slurp swaybg swaylock swayidle
    networkmanager network-manager-applet bluez bluez-utils blueman
    brightnessctl jq ffmpeg gstreamer gst-plugins-good gst-libav
    xdg-desktop-portal xdg-desktop-portal-hyprland
    ttf-jetbrains-mono-nerd ttf-font-awesome polkit-gnome
    power-profiles-daemon
)
AUR_PKGS=(greetd-tuigreet)

missing=()
for pkg in "${PACMAN_PKGS[@]}"; do
    pacman -Qi "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
fi
if ((${#missing[@]})); then
    echo -e "Installing packages: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
fi

if ((${#AUR_PKGS[@]})); then
    if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm "${AUR_PKGS[@]}"
    elif command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm "${AUR_PKGS[@]}"
    else
        echo -e "${YELLOW}AUR helper not found. Install ${AUR_PKGS[*]} manually.${RESET}"
    fi
fi

TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_SRC="$(cd "$(dirname "$0")" && pwd)/.config"
CONFIG_DEST="$TARGET_HOME/.config"
mkdir -p "$CONFIG_DEST"
for dir in hypr waybar wofi wlogout; do
    rm -rf "$CONFIG_DEST/$dir"
    cp -r "$CONFIG_SRC/$dir" "$CONFIG_DEST/"
    echo -e "${GREEN}Installed $dir config${RESET}"
    chown -R "$TARGET_USER":"$TARGET_USER" "$CONFIG_DEST/$dir"

done

echo -e "${GREEN}Package installation and config deployment complete.${RESET}"
