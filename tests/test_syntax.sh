#!/usr/bin/env bash
set -euo pipefail

fail=0
for script in *.sh; do
    if bash -n "$script"; then
        echo "$script: OK"
    else
        echo "$script: FAIL"
        fail=$((fail+1))
    fi
done

if ((fail)); then
    echo "$fail script(s) failed syntax check" >&2
    exit 1
fi

echo "All scripts passed syntax check"
