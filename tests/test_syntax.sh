#!/usr/bin/env bash
set -euo pipefail

fail=0

# Check syntax of all tracked shell scripts in the repository
while IFS= read -r script; do
    if bash -n "$script"; then
        echo "$script: OK"
    else
        echo "$script: FAIL"
        fail=$((fail+1))
    fi
done < <(git ls-files '*.sh')

if ((fail)); then
    echo "$fail script(s) failed syntax check" >&2
    exit 1
fi

echo "All scripts passed syntax check"
