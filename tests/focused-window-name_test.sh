#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# A window title with line breaks gives exactly two lines (full text,
# short text), the whole title on the first
OUTPUT=$(PATH="$(pwd)/fixtures/focused-window-name:${PATH}" PYTHONPATH="$(pwd)/fixtures/focused-window-name" python3 ../scripts/focused-window-name)
[ "$(printf '%s\n' "${OUTPUT}" | wc -l)" -eq 2 ]
printf '%s\n' "${OUTPUT}" | head -1 | grep -q -F 'first line second line third'
