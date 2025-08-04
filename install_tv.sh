#!/usr/bin/env bash
# install_tv.sh: set up TV app virtual environment
set -euo pipefail

GREEN="\e[32m"; RED="\e[31m"; RESET="\e[0m"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$REPO_DIR/.venv"
TV_REPO="https://github.com/TheZedxD/codexTest.git"
TV_DIR="$REPO_DIR/tv"

if [ -d "$TV_DIR/.git" ]; then
    git -C "$TV_DIR" pull --ff-only
else
    git clone "$TV_REPO" "$TV_DIR"
fi

python -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip
python -m pip install pyqt5 yt-dlp ffmpeg-python
if [ -f "$TV_DIR/requirements.txt" ]; then
    python -m pip install -r "$TV_DIR/requirements.txt"
fi
deactivate

echo -e "${GREEN}TV application environment ready in $VENV_DIR${RESET}"
