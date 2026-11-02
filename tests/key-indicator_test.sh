#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

export PATH="$(pwd)/fixtures/key-indicator:${PATH}"

# Both off: both letters in the bar background colour of the look
OUTPUT=$(TEST_LED_MASK=0 ../scripts/key-indicator)
echo "${OUTPUT}" | grep -q -F 'color="#393939">C</span>'
echo "${OUTPUT}" | grep -q -F 'color="#393939">N</span>'

# Caps Lock on, Num Lock off
OUTPUT=$(TEST_LED_MASK=1 ../scripts/key-indicator)
echo "${OUTPUT}" | grep -q -F 'color="#C0C0C0">C</span>'
echo "${OUTPUT}" | grep -q -F 'color="#393939">N</span>'

# Num Lock on, Caps Lock off
OUTPUT=$(TEST_LED_MASK=2 ../scripts/key-indicator)
echo "${OUTPUT}" | grep -q -F 'color="#393939">C</span>'
echo "${OUTPUT}" | grep -q -F 'color="#C0C0C0">N</span>'

# Resources from Regolith 2 still work
OUTPUT=$(TEST_LEGACY_RESOURCES=1 TEST_LED_MASK=0 ../scripts/key-indicator)
echo "${OUTPUT}" | grep -q -F 'color="#282828">C</span>'
