#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed \
  networkmanager network-manager-applet nm-connection-editor \
  polkit-gnome bluez bluez-utils blueman \
  pavucontrol helvum xfce4-power-manager udiskie \
  nwg-displays waybar && \
paru -S --needed hyprgui-git && \
systemctl enable --now NetworkManager bluetooth && \
hyprctl reload

