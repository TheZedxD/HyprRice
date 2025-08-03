# HyprRice

## Installation (Arch Linux)

1. Remove any previous copy, clone this repository, and run the installer:
   ```bash
   rm -rf HyprRice
   git clone https://github.com/YOUR_GITHUB_USERNAME/HyprRice.git
   cd HyprRice
   ./install.sh
   ```
   Replace `YOUR_GITHUB_USERNAME` with your GitHub account name. The script installs required packages, configures the `greetd` login manager and copies the configuration into `~/.config` for the current user.

### Packages installed

The install and update scripts ensure the following packages are present:

- alacritty
- archlinux-xdg-menu
- bluez
- bluez-utils
- blueman
- brightnessctl
- desktop-file-utils
- firefox
- grim
- gvfs
- gsimplecal
- greetd
- greetd-tuigreet
- htop
- hyprland
- jq
- ncdu
- network-manager-applet
- networkmanager
- nm-connection-editor
- nwg-look
- pipewire
- pipewire-alsa
- pipewire-pulse
- wireplumber
- alsa-utils
- pulsemixer
- polkit-gnome
- power-profiles-daemon
- slurp
- swaybg
- swayidle
- swaylock
- swaync
- thunar
- ttf-font-awesome
- ttf-jetbrains-mono-nerd
- waybar
- wlogout
- wofi
- xdg-desktop-portal
- xdg-desktop-portal-hyprland
- xfce4-power-manager
- xfce4-settings

On reboot you'll see a neon green `greetd` prompt. After authenticating, Hyprland starts automatically.

The installer attempts to grab the `tuigreet` greeter from the official repositories and falls back to `greetd-tuigreet-bin` via `yay` or `paru`. If no AUR helper is detected you'll need to install the greeter manually.

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
- Waybar modules show tooltips and launch pulsemixer, NetworkManager, calendar, and power settings when clicked
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

The install script installs all required packages including a polkit agent, notification daemon, NetworkManager, and the `greetd` login manager.

## Waybar Actions

| Module | Click Action |
|--------|--------------|
| Clock | Open `gsimplecal` calendar |
| Audio | Launch `pulsemixer` |
| Network | Launch `nm-connection-editor` |
| Battery | Open `xfce4-power-manager-settings` (provided by `xfce4-power-manager`) |
| Disk | Launch `ncdu` in Alacritty |

All modules display tooltips on hover.
