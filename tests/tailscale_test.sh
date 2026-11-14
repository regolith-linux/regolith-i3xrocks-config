#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

export LC_ALL=C.UTF-8

# Without tailscale installed the blocklet shows nothing and doesn't fail
EMPTY=$(mktemp -d)
trap 'rm -rf "$EMPTY"' EXIT
OUTPUT=$(PATH="$EMPTY" /bin/bash ../scripts/tailscale 2>&1)
[ -z "${OUTPUT}" ]

# With tailscale connected it shows the address
OUTPUT=$(PATH="$(pwd)/fixtures/tailscale:${PATH}" ../scripts/tailscale)
echo "${OUTPUT}" | grep -q -F '100.64.0.1</span>'
