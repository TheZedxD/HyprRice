#!/usr/bin/env bash
# fix_sound.sh: migrate PulseAudio to PipeWire and restart services
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; RESET="\e[0m"

echo -e "${GREEN}Switching to PipeWire audio stack...${RESET}"

if ! command -v pacman >/dev/null 2>&1; then
    echo -e "${RED}pacman not found. Aborting.${RESET}"
    exit 1
fi

PA_PKGS=$(pacman -Qq | grep -E '^pulseaudio' || true)
if [[ -n $PA_PKGS ]]; then
    echo -e "Removing PulseAudio: $PA_PKGS"
    sudo pacman -Rns --noconfirm $PA_PKGS
fi

REQ=(pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils pulsemixer)
missing=()
for p in "${REQ[@]}"; do
    pacman -Qi "$p" >/dev/null 2>&1 || missing+=("$p")
done
if ((${#missing[@]})); then
    sudo pacman -S --needed --noconfirm "${missing[@]}"
fi

systemctl --user enable --now pipewire pipewire-pulse wireplumber

sleep 2
if systemctl --user --quiet is-active pipewire && \
   systemctl --user --quiet is-active wireplumber; then
    echo -e "${GREEN}Audio services running${RESET}"
else
    echo -e "${RED}Audio services NOT running${RESET}"
    exit 1
fi

for card in /proc/asound/card?; do
    idx="${card##*card}"
    amixer -c "$idx" -q sset Master unmute 100% || true
    amixer -c "$idx" -q sset PCM unmute 100% || true
done

echo -e "${GREEN}Audio fix applied.${RESET}"
