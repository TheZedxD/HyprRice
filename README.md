# HyprRice

## Installation (Arch Linux)

1. Clone this repository and run the installer:
   ```bash
   git clone https://github.com/<your_user>/HyprRice.git
   cd HyprRice
   ./install.sh
   ```
   The script installs required packages and copies the configuration into `~/.config` for the current user.

## Update

After pulling the latest changes, run the updater to refresh your configuration:

```bash
./update.sh
```

## About

HyprRice is a matrix-inspired configuration for the [Hyprland](https://github.com/hyprwm/Hyprland) Wayland compositor. It aims for a clean and minimal look with sharp edges and bright green accents.

## Features

- Neon green "Matrix" theme with solid active/inactive borders
- Zero window rounding and no shadows for a crisp aesthetic
- Animations disabled for snappy performance
- Small inner gaps for tiling and a minimal top gap for Waybar
- Waybar for system status and Wofi as application launcher
- Waybar modules show tooltips and launch pavucontrol or NetworkManager when clicked
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
| **Super + C** | Toggle centered floating zoom |
| **Super + V** | Center window |
| **Super + Arrow Keys** | Move focus left/down/up/right |
| **Super + Ctrl + Arrow Keys** | Move window to adjacent workspace |
| **Super + [1-9]** | Switch to workspace 1-9 |

## Notes

The install script attempts to install all required packages. Additional tools like a polkit agent or notification daemon may be needed for a full desktop experience.

## Waybar Actions

| Module | Click Action |
|--------|--------------|
| Clock | Open calendar in Alacritty |
| Audio | Launch `pavucontrol` |
| Network | Launch `nmtui` in Alacritty |

All modules display tooltips on hover.
