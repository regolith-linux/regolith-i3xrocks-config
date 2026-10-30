#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
ln -s "$SCRIPT_DIR/xrescat_mock" "$WORK/xrescat"
export PATH="$WORK:$SCRIPT_DIR/fixtures/offline:$PATH"
export BASH_ENV="$SCRIPT_DIR/fixtures/offline/bash-env"
for test in "$SCRIPT_DIR"/*_test.sh; do
    case "${test##*/}" in
        net-traffic_test.sh | nm-vpn_test.sh | memory_test.sh) umockdev-run -- bash "$test" ;;
        *) bash "$test" ;;
    esac
done
