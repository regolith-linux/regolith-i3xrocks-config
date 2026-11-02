#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

export PATH="$(pwd)/fixtures/wifi:${PATH}"

# not connected: no output, even with a neighbour network called "yes:..."
[ -z "$(../scripts/wifi)" ]

OUTPUT=$(TEST_SSID='Home' ../scripts/wifi)
echo "${OUTPUT}" | head -1 | grep -q -F '> Home</span>'

# ':' and '\' as they are, '&' '<' '>' escaped for Pango
OUTPUT=$(TEST_SSID='R&D:Lab' ../scripts/wifi)
echo "${OUTPUT}" | head -1 | grep -q -F '> R&amp;D:Lab</span>'
echo "${OUTPUT}" | sed -n 2p | grep -q -F '> R&amp;D:Lab</span>'
OUTPUT=$(TEST_SSID='a\b <5G>' ../scripts/wifi)
echo "${OUTPUT}" | head -1 | grep -q -F '> a\b &lt;5G&gt;</span>'

# non-ASCII and apostrophes
OUTPUT=$(TEST_SSID="Café d'Écosse" ../scripts/wifi)
echo "${OUTPUT}" | head -1 | grep -q -F "> Café d'Écosse</span>"
