#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# With the notification daemon down, the blocklet shows 0 and succeeds
OUTPUT=$(PATH="$(pwd)/fixtures/rofication/down:${PATH}" ../scripts/rofication)
echo "${OUTPUT}" | grep -q -F '>0</span>'

# With notifications, it shows critical/total
OUTPUT=$(PATH="$(pwd)/fixtures/rofication/some:${PATH}" ../scripts/rofication)
echo "${OUTPUT}" | grep -q -F '>1/3</span>'
