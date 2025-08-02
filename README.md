# HyprRice

## Installation (Arch Linux)

1. Install required packages:
   ```bash
   sudo pacman -S hyprland waybar wofi alacritty swaybg dolphin firefox
   ```
2. Clone this repository and run the installer:
   ```bash
   git clone https://github.com/<your_user>/HyprRice.git
   cd HyprRice
   ./install.sh
   ```
   The script copies the configuration into `~/.config` for the current user.

## About

HyprRice is a matrix-inspired configuration for the [Hyprland](https://github.com/hyprwm/Hyprland) Wayland compositor. It aims for a clean and minimal look with sharp edges and bright green accents.

## Features

- Neon green "Matrix" theme with solid active/inactive borders
- Zero window rounding and no shadows for a crisp aesthetic
- Animations disabled for snappy performance
- Small inner gaps for tiling and no outer gaps
- Waybar for system status and Wofi as application launcher
- Autostarts Waybar and an Alacritty terminal
- Solid black wallpaper via swaybg

## Keybindings

| Keybinding | Action |
|------------|--------|
| **Super + Enter** | Open Alacritty terminal |
| **Super + Space** | Launch Wofi app launcher |
| **Super + Q** | Close focused window |
| **Super + F** | Launch Dolphin file manager |
| **Super + B** | Launch Firefox browser |
| **Super + C** / **Super + V** | Toggle floating mode |
| **Super + V** | Center window on screen |
| **Super + Arrow Keys** | Move focus left/down/up/right |
| **Super + Ctrl + Left/Right** | Move window to previous/next workspace |
| **Super + [1-9]** | Switch to workspace 1-9 |

## Notes

Ensure required packages are installed before running the installer. Additional tools like a polkit agent or notification daemon may be needed for a full desktop experience.
