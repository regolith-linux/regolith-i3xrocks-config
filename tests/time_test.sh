#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

export PATH="$(pwd)/fixtures/time:${PATH}"
export LC_ALL=C.UTF-8

# 24-hour clock
OUTPUT=$(TEST_CLOCK_FORMAT=24h ../scripts/time)
echo "${OUTPUT}" | grep -q -F '> 29/10 00:02 </span>'
OUTPUT=$(TEST_CLOCK_FORMAT=24h TEST_TIME='2026-10-29 13:45' ../scripts/time)
echo "${OUTPUT}" | grep -q -F '> 29/10 13:45 </span>'

# 12-hour clock: midnight and noon must differ
OUTPUT=$(TEST_CLOCK_FORMAT=12h ../scripts/time)
echo "${OUTPUT}" | grep -q -F '> 29/10 12:02 AM </span>'
OUTPUT=$(TEST_CLOCK_FORMAT=12h TEST_TIME='2026-10-29 12:02' ../scripts/time)
echo "${OUTPUT}" | grep -q -F '> 29/10 12:02 PM </span>'
OUTPUT=$(TEST_CLOCK_FORMAT=12h TEST_TIME='2026-10-29 13:45' ../scripts/time)
echo "${OUTPUT}" | grep -q -F '> 29/10 01:45 PM </span>'
