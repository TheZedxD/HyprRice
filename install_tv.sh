#!/usr/bin/env bash
# install_tv.sh: set up TV app virtual environment
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; RESET="\e[0m"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$REPO_DIR/.venv"
TV_REPO="https://github.com/TheZedxD/codexTest.git"
TV_DIR="$REPO_DIR/tv"

echo -e "${GREEN}Installing system dependencies (sudo password may be required)...${RESET}"
if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git python python-pip python-virtualenv ffmpeg qt5-base qt5-multimedia qt5-wayland
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git python3 python3-venv python3-pip ffmpeg python3-pyqt5 python3-pyqt5.qtwebengine
else
    echo -e "${YELLOW}No supported package manager found. Install git, python3, python3-venv, python3-pip, ffmpeg and PyQt5 manually.${RESET}"
fi

if [ -d "$TV_DIR/.git" ]; then
    git -C "$TV_DIR" pull --ff-only
else
    git clone "$TV_REPO" "$TV_DIR"
fi

PYTHON_BIN="$(command -v python3 || command -v python)"
"$PYTHON_BIN" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip
python -m pip install pyqt5 yt-dlp ffmpeg-python
if [ -f "$TV_DIR/requirements.txt" ]; then
    python -m pip install -r "$TV_DIR/requirements.txt"
fi
deactivate

echo -e "${GREEN}TV application environment ready in $VENV_DIR${RESET}"
