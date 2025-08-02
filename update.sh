#!/usr/bin/env bash
# Simple updater for HyprRice dotfiles.
# Pulls latest git changes and re-installs configuration.
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER:-$(id -un)}}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
DIRS=(alacritty hypr waybar wofi)

# Ensure required packages are installed
needed=(
    alacritty
    hyprland
    waybar
    wofi
    swaybg
    dolphin
    firefox
    pavucontrol
    networkmanager
    nm-connection-editor
    xfce4-power-manager-settings
    htop
    ncdu
    jq
)
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

if git remote get-url origin >/dev/null 2>&1; then
    echo -e "\nPulling latest changes..."
    git pull --rebase --autostash
else
    echo -e "\nNo git remote configured; skipping pull."
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
