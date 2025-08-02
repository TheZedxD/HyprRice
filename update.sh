#!/usr/bin/env bash
# Simple updater for HyprRice dotfiles.
# Pulls latest git changes and re-installs configuration.
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER:-$(id -un)}}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
DIRS=(alacritty hypr waybar wofi)

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
