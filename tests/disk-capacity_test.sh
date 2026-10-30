#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# Initial run without defining a device
PATH="$(pwd)/fixtures/disk-capacity/first:${PATH}"
OUTPUT=$(../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -P '\>133G\<'

# Now with a device set
MNT="/mnt"
export MNT

PATH="$(pwd)/fixtures/disk-capacity/second:${PATH}"
OUTPUT=$(../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -P '\>213G\<'

# The value colour follows the used percentage: 83% is above the default
# warning threshold (80), 97% above the critical one (90).
echo "${OUTPUT}" | grep -q -F 'color="#EBCB8B">213G<'

unset MNT
OUTPUT=$(PATH="$(pwd)/fixtures/disk-capacity/first:${PATH}" ../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9">133G<'

PATH="$(pwd)/fixtures/disk-capacity/third:${PATH}"
OUTPUT=$(../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -F 'color="#BF616A">4.1G<'

# Thresholds and colours from block properties
OUTPUT=$(critical_threshold=98 ../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -F 'color="#EBCB8B">4.1G<'
OUTPUT=$(warning_threshold=98 critical_threshold=99 ../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9">4.1G<'
OUTPUT=$(critical_color="#ff0000" ../scripts/disk-capacity)
echo "${OUTPUT}" | grep -q -F 'color="#ff0000">4.1G<'
