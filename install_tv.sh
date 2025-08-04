#!/usr/bin/env bash
# install_tv.sh: Clone and set up the optional TV application
set -Eeuo pipefail

handle_error() {
    local exit_code=$?
    local line_number=$1
    local command=$2
    echo "ERROR: Command failed with exit code $exit_code at line $line_number: $command" >&2
    exit $exit_code
}

trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

TV_REPO="https://github.com/TheZedxD/codexTest.git"
TV_DIR="$HOME/codexTest"

if [ -d "$TV_DIR/.git" ]; then
    echo "TV app directory already exists. Pulling latest changes..."
    git -C "$TV_DIR" pull --ff-only || true
else
    echo "Cloning TV app repository to $TV_DIR..."
    git clone "$TV_REPO" "$TV_DIR"
fi

if [ -f "$TV_DIR/requirements.txt" ]; then
    echo "Installing Python dependencies for TV app..."
    python3 -m pip install --upgrade pip
    python3 -m pip install -r "$TV_DIR/requirements.txt"
fi

MAIN_SCRIPT=""
for candidate in app.py main.py; do
    if [ -f "$TV_DIR/$candidate" ]; then
        MAIN_SCRIPT="$TV_DIR/$candidate"
        break
    fi
done
[ -z "$MAIN_SCRIPT" ] && MAIN_SCRIPT="$TV_DIR/app.py"

APPDESK="$HOME/.local/share/applications/TVApp.desktop"
mkdir -p "$(dirname "$APPDESK")"
cat >"$APPDESK" <<EOF
[Desktop Entry]
Type=Application
Name=TV Media App
Comment=Launch the TV streaming application
Exec=python3 $MAIN_SCRIPT
Icon=video-display
Terminal=false
Categories=AudioVideo;
EOF

echo "TV application installed. Launch it from your application menu or by running 'python3 $MAIN_SCRIPT'."

