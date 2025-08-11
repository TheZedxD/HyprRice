#!/usr/bin/env bash
# Simple updater for HyprRice dotfiles.
# Pulls latest git changes and re-installs configuration.
set -Eeuo pipefail

handle_error() {
    local exit_code=$?
    local line_number=$1
    local command=$2
    echo "ERROR: Command failed with exit code $exit_code at line $line_number: $command" >&2
    exit $exit_code
}

trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

TARGET_USER=${SUDO_USER:-${USER:-$(id -un)}}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
DIRS=(alacritty hypr waybar wofi wlogout)

APP_DIR="$TARGET_HOME/.local/share/applications"
UPDATE_DESKTOP="$APP_DIR/hyprrice-update.desktop"
mkdir -p "$APP_DIR"
cat > "$UPDATE_DESKTOP" <<EOF
[Desktop Entry]
Name=HyprRice Update
Exec=$SCRIPT_DIR/.update
Terminal=true
Type=Application
Icon=system-software-update
Categories=System;
EOF
chown "$TARGET_USER":"$TARGET_USER" "$UPDATE_DESKTOP" || true

# Capture Hyprland instance signature so hyprctl can talk to the running compositor
HYPR_SIG=$(sudo -u "$TARGET_USER" printenv HYPRLAND_INSTANCE_SIGNATURE 2>/dev/null || true)

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
    bluez
    bluez-utils
    blueman
    brightnessctl
    desktop-file-utils
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
    sudo -u "$TARGET_USER" update-desktop-database "$APP_DIR" || true
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
    sudo systemctl enable greetd.service || true
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

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "\nFetching latest changes..."
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
    if git fetch origin "$current_branch"; then
        git reset --hard "origin/$current_branch" || true
    else
        echo "Git fetch failed; skipping update."
    fi
else
    echo -e "\nNot a git repository; skipping update."
fi
step=$((step+1))
progress $step $total

mkdir -p "$CONFIG_DEST"
for dir in "${DIRS[@]}"; do
    echo -e "\nSyncing $dir configuration..."
    src="$SCRIPT_DIR/.config/$dir/"
    dest="$CONFIG_DEST/$dir/"
    mkdir -p "$dest"
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete "$src" "$dest"
    else
        rm -rf "$dest"
        mkdir -p "$dest"
        cp -r "$src" "$dest"
    fi
    chown -R "$TARGET_USER":"$TARGET_USER" "$dest" || true
    step=$((step+1))
    progress $step $total
done

# Install helper and shortcut scripts
sudo install -m 755 "$SCRIPT_DIR/scripts/hyprrice-help.sh" /usr/local/bin/hyprrice-help.sh

mkdir -p "$TARGET_HOME/.config/hypr/scripts"
sudo install -m 755 "$SCRIPT_DIR/scripts/show_shortcuts.sh" "$TARGET_HOME/.config/hypr/scripts/show_shortcuts.sh"
chown "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.config/hypr/scripts/show_shortcuts.sh" || true

sudo install -m 644 "$SCRIPT_DIR/scripts/hyprrice-shortcuts.desktop" "$APP_DIR/hyprrice-shortcuts.desktop"
chown "$TARGET_USER":"$TARGET_USER" "$APP_DIR/hyprrice-shortcuts.desktop" || true
sudo -u "$TARGET_USER" update-desktop-database "$APP_DIR" || true

# Install Python Arcade desktop entry if available
sudo -u "$TARGET_USER" bash -c "source '$SCRIPT_DIR/scripts/install_python_arcade_desktop.sh' && install_python_arcade_desktop"

# Install or update the optional TV streaming application
if [[ -x "$SCRIPT_DIR/install_tv.sh" ]]; then
    "$SCRIPT_DIR/install_tv.sh" || true
fi

# Validate configuration
if [[ -x "$SCRIPT_DIR/validate.sh" ]]; then
    sudo -u "$TARGET_USER" "$SCRIPT_DIR/validate.sh" || echo "Validation reported issues."
fi

if command -v hyprctl >/dev/null 2>&1; then
    echo -e "\nReloading Hyprland configuration..."
    if [[ -n "$HYPR_SIG" ]]; then
        sudo -u "$TARGET_USER" HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG" hyprctl reload || true
    else
        sudo -u "$TARGET_USER" hyprctl reload || true
    fi
    # reload waybar to pick up new configuration
    sudo -u "$TARGET_USER" pkill -SIGUSR2 waybar 2>/dev/null || true
fi

if [[ -x "$SCRIPT_DIR/system_check.sh" ]]; then
    "$SCRIPT_DIR/system_check.sh" || true
fi

echo -e "\nHyprRice update complete."
