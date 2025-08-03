#!/usr/bin/env bash
# fix_sound.sh — purge PulseAudio, enable PipeWire, unmute channels

set -uo pipefail
RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; BOLD='\e[1m'; RESET='\e[0m'

echo -e "${BOLD}${GREEN}▶ HyprRice Audio Repair${RESET}"

## 1) Remove PulseAudio packages
PA_PKGS=$(pacman -Qq | grep -E '^pulseaudio' || true)
if [[ -n $PA_PKGS ]]; then
  echo -e "${YELLOW}Removing PulseAudio packages:${RESET} $PA_PKGS"
  sudo pacman -Rns --noconfirm $PA_PKGS
else
  echo -e "${GREEN}[OK] No PulseAudio packages detected.${RESET}"
fi

## 2) Ensure PipeWire stack present
REQ=(pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils pulsemixer)
missing=()
for p in "${REQ[@]}"; do
  pacman -Qi "$p" &>/dev/null || missing+=("$p")
done
if (( ${#missing[@]} )); then
  echo -e "${YELLOW}Installing:${RESET} ${missing[*]}"
  sudo pacman -S --noconfirm "${missing[@]}"
fi

## 3) Enable + start services
systemctl --user enable --now pipewire pipewire-pulse wireplumber

## 4) Unmute Master/PCM on all cards
for card in /proc/asound/card?; do
  idx="${card##*card}"
  amixer -c "$idx" -q sset Master unmute 100% || true
  amixer -c "$idx" -q sset PCM    unmute 100% || true
done

## 5) Quick verification
sleep 2
if systemctl --user --quiet is-active pipewire && \
   systemctl --user --quiet is-active wireplumber; then
   echo -e "${GREEN}✔ Audio services running.${RESET}"
else
   echo -e "${RED}✖ PipeWire services NOT active! Check journalctl --user -u pipewire.${RESET}"
fi

echo -e "${BOLD}${YELLOW}→ REBOOT NOW to complete audio repair.${RESET}"
