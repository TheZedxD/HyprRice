#!/usr/bin/env bash
set -euo pipefail

# Ensure tests are executable
chmod +x tests/test_syntax.sh

# Run tests
bash tests/test_syntax.sh
