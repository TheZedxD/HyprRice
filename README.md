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
- Waybar modules show tooltips and launch pavucontrol, NetworkManager, calendar, and power settings when clicked
- Autostarts Waybar along with a polkit agent, NetworkManager, Bluetooth, power and notification applets
- Solid black wallpaper via swaybg

## Keybindings

| Keybinding | Action |
|------------|--------|
| **Super + Enter** | Open Alacritty terminal |
| **Super + Space** | Launch Wofi app launcher |
| **Super + E** | Open Thunar file manager |
| **Super + B** | Launch Firefox browser |
| **Super + L** | Lock the screen |
| **Super + M** | Open logout menu |
| **Super + Q** | Close focused window |
| **Super + W** | Force close window |
| **Super + F** | Toggle fullscreen |
| **Super + V** | Toggle floating mode |
| **Super + J** | Toggle split orientation |
| **Super + Arrow Keys** | Focus window left/down/up/right |
| **Super + Shift + Arrow Keys** | Move window left/down/up/right |
| **Super + Ctrl + Arrow Keys** | Send window to adjacent workspace |
| **Super + [1-9]** | Switch to workspace 1-9 |
| **Super + Shift + [1-9]** | Move window to workspace 1-9 |
| **Super + Tab** | Switch to previous workspace |
| **Alt + Tab** | Cycle through windows |
| **Print** | Screenshot full screen |
| **Super + S** | Screenshot region |

## Notes

The install script installs all required packages including a polkit agent, notification daemon, and NetworkManager.

## Waybar Actions

| Module | Click Action |
|--------|--------------|
| Clock | Open `gsimplecal` calendar |
| Audio | Launch `pavucontrol` |
| Network | Launch `nm-connection-editor` |
| Battery | Open `xfce4-power-manager-settings` |
| Disk | Launch `ncdu` in Alacritty |

All modules display tooltips on hover.
