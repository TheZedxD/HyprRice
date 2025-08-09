#!/usr/bin/env bash
set -euo pipefail

install_python_arcade_desktop() {
    local arcade_dir="$HOME/PythonArcade/arcade"
    if [[ ! -d "$arcade_dir" ]]; then
        echo "PythonArcade not found; skipping desktop entry."
        return 0
    fi

    mkdir -p "$HOME/.local/share/applications"
    local desktop_path="$HOME/.local/share/applications/python-arcade.desktop"
    local tmp_file
    tmp_file="$(mktemp)"

    cat >"$tmp_file" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Python Arcade
Comment=Matrix-style mini-game hub (Pygame)
Exec=/bin/bash -lc 'cd ~/PythonArcade/arcade && ./run.sh || (SDL_VIDEODRIVER=wayland python main.py || SDL_VIDEODRIVER=x11 python main.py)'
Icon=applications-games
Terminal=false
Categories=Game;
DESKTOP

    mv "$tmp_file" "$desktop_path"

    update-desktop-database "$HOME/.local/share/applications" || true
    desktop-file-validate "$desktop_path" || true

    echo "Python Arcade desktop entry installed."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_python_arcade_desktop "$@"
fi
