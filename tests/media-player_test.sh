#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# Line breaks in the artist or title stay out of the block's lines:
# exactly two lines (full text, short text), the text (trimmed) on the first
OUTPUT=$(PATH="$(pwd)/fixtures/media-player:${PATH}" ../scripts/media-player)
[ "$(printf '%s\n' "${OUTPUT}" | wc -l)" -eq 2 ]
printf '%s\n' "${OUTPUT}" | head -1 | grep -q -F 'Artist Second'
