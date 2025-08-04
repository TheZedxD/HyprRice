#!/usr/bin/env bash
# Simple installer for HyprRice dotfiles.
# Copies configuration files into the current user's ~/.config directory.
# If run with sudo, files will be placed in the invoking user's home.
set -euo pipefail

TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

printf 'Installing configuration for user %s in %s\n' "$TARGET_USER" "$CONFIG_DEST"

# Ensure PipeWire audio stack
if command -v pacman >/dev/null 2>&1; then
    PA_PKGS=$(pacman -Qq | grep -E '^pulseaudio' || true)
    if [[ -n $PA_PKGS ]]; then
        sudo pacman -Rns --noconfirm $PA_PKGS || true
    fi
    sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils pulsemixer
    sudo -u "$TARGET_USER" systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
    echo -e '\e[1;33mAudio stack switched to PipeWire. You must REBOOT for changes to take full effect.\e[0m'
fi

# Ensure required packages are installed
# Added swappy for screenshot annotation and xorg-xwayland for X11 support
packages=(
    alacritty
    archlinux-xdg-menu
    desktop-file-utils
    bluez
    bluez-utils
    blueman
    brightnessctl
    firefox
    grim
    gvfs
    greetd
    greetd-tuigreet
    htop
    hyprland
    jq
    ncdu
    networkmanager
    network-manager-applet
    nm-connection-editor
    nwg-look
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    alsa-utils
    pulsemixer
    polkit-gnome
    power-profiles-daemon
    slurp
    swappy
    swaybg
    swayidle
    swaylock
    swaync
    thunar
    ttf-font-awesome
    ttf-jetbrains-mono-nerd
    util-linux
    ffmpeg
    gstreamer
    gst-plugins-good
    gst-libav
    python
    python-pip
    python-virtualenv
    python-pyqt5
    qt5-multimedia
    qt5-wayland
    yt-dlp
    waybar
    wlogout
    wofi
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xfce4-power-manager
    xfce4-settings
    xorg-xwayland
)
if command -v pacman >/dev/null 2>&1; then
    missing=()
    aur_missing=()
    for pkg in "${packages[@]}"; do
        if pacman -Qi "$pkg" >/dev/null 2>&1; then
            continue
        elif pacman -Si "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        else
            aur_missing+=("$pkg")
        fi
    done
    if ((${#missing[@]})); then
        printf 'Installing missing dependencies: %s\n' "${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
    for pkg in "${aur_missing[@]}"; do
        case "$pkg" in
            greetd-tuigreet) aur_pkg="greetd-tuigreet-bin";;
            *) aur_pkg="$pkg";;
        esac
        if command -v yay >/dev/null 2>&1; then
            yay -S --needed --noconfirm "$aur_pkg" || true
        elif command -v paru >/dev/null 2>&1; then
            paru -S --needed --noconfirm "$aur_pkg" || true
        else
            printf 'Please install %s manually from the AUR.\n' "$aur_pkg"
        fi
    done
else
    printf 'Warning: pacman not found; cannot verify dependencies.\n'
fi

# Ensure a `python` command is available for virtual environments
if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    sudo ln -sf "$(command -v python3)" /usr/bin/python
fi

# Rebuild application menus and ensure portals/services are running
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" XDG_MENU_PREFIX=arch- kbuildsycoca6 || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" update-desktop-database || true
fi
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now NetworkManager.service || true
    sudo systemctl enable --now bluetooth.service || true
    sudo systemctl enable --now power-profiles-daemon.service || true
    sudo -u "$TARGET_USER" systemctl --user restart xdg-desktop-portal-hyprland.service || true
    DM_SERVICES=(gdm.service sddm.service lightdm.service lxdm.service ly.service)
    for svc in "${DM_SERVICES[@]}"; do
        sudo systemctl disable --now "$svc" >/dev/null 2>&1 || true
    done
    sudo systemctl enable --now greetd.service || true
fi

if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p /etc/greetd
    sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --user-menu --cmd Hyprland --theme 'text=green;prompt=green;input=green;container=black;border=green;title=green;action=green;button=green'"
user = "greeter"
EOF
fi

DIRS=(alacritty hypr waybar wofi)

progress() {
    local current=$1 total=$2 width=30
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local bar
    bar=$(printf "%${filled}s" | tr ' ' '#')
    printf '\r[%-*s] %d%%' "$width" "$bar" "$percent"
}

mkdir -p "$CONFIG_DEST"
total=${#DIRS[@]}
step=0
progress $step $total
for dir in "${DIRS[@]}"; do
    rm -rf "$CONFIG_DEST/$dir"
    cp -r ".config/$dir" "$CONFIG_DEST/"
    step=$((step+1))
    progress $step $total
    printf '\nInstalled %s configuration.\n' "$dir"
done

# Validate configuration
if [[ -x "$SCRIPT_DIR/validate.sh" ]]; then
    sudo -u "$TARGET_USER" "$SCRIPT_DIR/validate.sh" || echo "Validation reported issues."
fi

echo -e '\nHyprRice installation complete.'

echo 'Reboot to be greeted by a green-on-black login and Hyprland session.'
