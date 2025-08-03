#!/usr/bin/env bash
# Simple updater for HyprRice dotfiles.
# Pulls latest git changes and re-installs configuration.
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER:-$(id -un)}}
TARGET_HOME=$(eval echo "~$TARGET_USER")
CONFIG_DEST="$TARGET_HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIRS=(alacritty hypr waybar wofi)

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
    gsimplecal
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
    git fetch origin "$current_branch"
    git reset --hard "origin/$current_branch"
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
        rm -rf "$CONFIG_DEST/$dir"
        cp -r "$src" "$CONFIG_DEST/"
    fi
    chown -R "$TARGET_USER":"$TARGET_USER" "$CONFIG_DEST/$dir" || true
    step=$((step+1))
    progress $step $total
done

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
fi

echo -e "\nHyprRice update complete."
