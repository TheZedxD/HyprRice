#!/usr/bin/env bash
# run_tv.sh: launch TV application using bundled virtual environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
TV_DIR="$SCRIPT_DIR/tv"

APP_SCRIPT=""
for candidate in app.py main.py tv.py; do
    if [ -f "$TV_DIR/$candidate" ]; then
        APP_SCRIPT="$TV_DIR/$candidate"
        break
    fi
done

if [ -z "$APP_SCRIPT" ]; then
    echo "No entry script found in $TV_DIR" >&2
    exit 1
fi

cd "$TV_DIR"
exec "$VENV_DIR/bin/python" "$APP_SCRIPT" "$@"
