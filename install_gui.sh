#!/usr/bin/env bash
set -euo pipefail

USER_TO_RUN=${SUDO_USER:-$USER}

sudo pacman -S --needed \
  archlinux-xdg-menu desktop-file-utils \
  xdg-desktop-portal xdg-desktop-portal-hyprland \
  networkmanager network-manager-applet nm-connection-editor \
  polkit-gnome bluez bluez-utils blueman \
  pavucontrol helvum xfce4-power-manager udiskie \
  nwg-displays waybar alacritty swaybg wofi firefox dolphin hyprland jq htop ncdu && \
paru -S --needed hyprgui-git && \
systemctl enable --now NetworkManager bluetooth && \
sudo -u "$USER_TO_RUN" systemctl --user restart xdg-desktop-portal-hyprland.service || true && \
sudo -u "$USER_TO_RUN" XDG_MENU_PREFIX=arch- kbuildsycoca6 || true && \
hyprctl reload

