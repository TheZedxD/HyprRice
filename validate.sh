#!/usr/bin/env bash
# Validation script for HyprRice configuration
set -uo pipefail

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
BOLD='\e[1m'
RESET='\e[0m'

errors=0

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$REPO_DIR/.config"
HYPR_CONF="$CONFIG_DIR/hypr/hyprland.conf"
WAYBAR_CONF="$CONFIG_DIR/waybar/config"

echo -e "${BLUE}Auto-formatting Hyprland config...${RESET}"
if [[ -f "$HYPR_CONF" ]]; then
    sed -i 's/[ \t]*$//' "$HYPR_CONF"
fi

echo -e "${BLUE}Checking Hyprland config syntax...${RESET}"
if [[ ! -f "$HYPR_CONF" ]]; then
    echo -e "Hyprland config ${RED}[ERROR]${RESET}: file not found at $HYPR_CONF"
    errors=$((errors+1))
else
    open_braces=$(grep -o '{' "$HYPR_CONF" | wc -l)
    close_braces=$(grep -o '}' "$HYPR_CONF" | wc -l)
    if [[ $open_braces -ne $close_braces ]]; then
        echo -e "Brace balance ${RED}[ERROR]${RESET}: {=$open_braces }=$close_braces"
        errors=$((errors+1))
    else
        echo -e "Brace balance ${GREEN}[OK]${RESET}"
    fi

    bad_binds=$(grep '^bind\s*=\s*' "$HYPR_CONF" | while read -r line; do
        fields=$(awk -F',' '{print NF}' <<<"$line")
        if ((fields<3 || fields>4)); then
            echo "$line"
        fi
    done)
    if [[ -n "$bad_binds" ]]; then
        echo -e "Keybinding format ${RED}[ERROR]${RESET}:" && echo "$bad_binds"
        errors=$((errors+1))
    else
        echo -e "Keybinding format ${GREEN}[OK]${RESET}"
    fi
fi

echo -e "${BLUE}Running Hyprland --validate...${RESET}"
if command -v hyprland >/dev/null 2>&1; then
    if hyprland --config "$HYPR_CONF" --validate >/tmp/hypr_validate 2>&1; then
        echo -e "Hyprland validation ${GREEN}[OK]${RESET}"
    else
        echo -e "Hyprland validation ${RED}[ERROR]${RESET}:"
        cat /tmp/hypr_validate
        errors=$((errors+1))
    fi
else
    echo -e "${YELLOW}[WARN]${RESET} hyprland not found; skipping full config validation"
fi

echo -e "${BLUE}Checking Hyprland exec commands...${RESET}"
if [[ -f "$HYPR_CONF" ]]; then
    declare -A seen
    missing_execs=()
    while read -r line; do
        cmd=$(echo "$line" | sed 's/^exec-once *= *//' | awk '{print $1}')
        if [[ "$cmd" == /* ]]; then
            [[ -x "$cmd" ]] || missing_execs+=("$cmd")
        else
            command -v "$cmd" >/dev/null 2>&1 || missing_execs+=("$cmd")
        fi
        if [[ "$line" == *"swaylock"* ]]; then
            command -v swaylock >/dev/null 2>&1 || missing_execs+=("swaylock")
        fi
    done < <(grep '^exec-once' "$HYPR_CONF")

    unique_missing=()
    for m in "${missing_execs[@]}"; do
        [[ -n ${seen[$m]:-} ]] || { unique_missing+=("$m"); seen[$m]=1; }
    done
    if ((${#unique_missing[@]})); then
        echo -e "Exec commands ${RED}[ERROR]${RESET}: ${unique_missing[*]}"
        errors=$((errors+1))
    else
        echo -e "Exec commands ${GREEN}[OK]${RESET}"
    fi
fi

echo -e "${BLUE}Validating Waybar config...${RESET}"
if command -v jq >/dev/null 2>&1; then
    if jq empty "$WAYBAR_CONF" >/dev/null 2>&1; then
        echo -e "Waybar JSON ${GREEN}[OK]${RESET}"
    else
        echo -e "Waybar JSON ${RED}[ERROR]${RESET}"
        errors=$((errors+1))
    fi
else
    echo -e "${YELLOW}[WARN]${RESET} jq not found; skipping Waybar JSON validation"
fi

# Commands that Waybar modules rely on. The power manager settings binary is
# provided by the xfce4-power-manager package, so we check for the package's
# main command here.
WAYBAR_CMDS=(cal pulsemixer nm-connection-editor alacritty htop ncdu xfce4-power-manager)
missing_waybar=()
for cmd in "${WAYBAR_CMDS[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing_waybar+=("$cmd")
done
if ((${#missing_waybar[@]})); then
    echo -e "Waybar commands ${RED}[ERROR]${RESET}: ${missing_waybar[*]}"
    errors=$((errors+1))
else
    echo -e "Waybar commands ${GREEN}[OK]${RESET}"
fi

echo -e "${BLUE}Checking required packages...${RESET}"
packages=(
    alacritty archlinux-xdg-menu bluez bluez-utils blueman brightnessctl desktop-file-utils firefox grim gvfs greetd
greetd-tuigreet htop hyprland jq ncdu networkmanager network-manager-applet nm-connection-editor nwg-look pipewire pipewire-pulse pipewire-alsa wireplumber alsa-utils pulsemixer polkit-gnome power-profiles-daemon slurp swappy swaybg swayidle swaylock swaync thunar ttf-font-awesome ttf-jetbrains-mono-nerd util-linux waybar wlogout wofi xdg-desktop-portal xdg-desktop-portal-hyprland xfce4-power-manager xfce4-settings xorg-xwayland
)
if command -v pacman >/dev/null 2>&1; then
    missing_pkgs=()
    for pkg in "${packages[@]}"; do
        pacman -Qi "$pkg" >/dev/null 2>&1 || missing_pkgs+=("$pkg")
    done
    if ((${#missing_pkgs[@]})); then
        echo -e "Package check ${RED}[ERROR]${RESET}: ${missing_pkgs[*]}"
        errors=$((errors+1))
    else
        echo -e "Package check ${GREEN}[OK]${RESET}"
    fi
else
    echo -e "${YELLOW}[WARN]${RESET} pacman not found; skipping package check"
fi

echo -e "${BLUE}Scanning Hyprland logs...${RESET}"
log_file="$HOME/.cache/hyprland/hyprland.log"
if [[ -f "$log_file" ]]; then
    log_lines=$(grep -iE 'error|warning' "$log_file")
    if [[ -n "$log_lines" ]]; then
        while IFS= read -r l; do
            echo -e "${BLUE}[LOG]${RESET} $l"
        done <<<"$log_lines"
    else
        echo -e "Log scan ${GREEN}[OK]${RESET}"
    fi
else
    echo -e "${YELLOW}[WARN]${RESET} No Hyprland log found at $log_file"
fi

if ((errors>0)); then
    echo -e "${RED}${BOLD}Validation completed with errors.${RESET}"
    exit 1
else
    echo -e "${GREEN}${BOLD}All checks passed.${RESET}"
    exit 0
fi

