#!/bin/bash

set -Eeux -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export PATH="${SCRIPT_DIR}/fixtures/battery:${PATH}"
unset button

# Without an instance the blocklet shows UPower's combined DisplayDevice
OUTPUT=$(env -u BLOCK_INSTANCE "${SCRIPT_DIR}/../scripts/battery")
[[ "${OUTPUT}" == *'> 62%</span>'* ]]

# Kernel names (as documented in conf.d/80_battery), UPower device names and
# full object paths all select the same battery
for instance in BAT0 battery_BAT0 /org/freedesktop/UPower/devices/battery_BAT0; do
    OUTPUT=$(BLOCK_INSTANCE="${instance}" "${SCRIPT_DIR}/../scripts/battery")
    [[ "${OUTPUT}" == *'> 85%</span>'* ]]
done

# A second battery
for instance in BAT1 battery_BAT1; do
    OUTPUT=$(BLOCK_INSTANCE="${instance}" "${SCRIPT_DIR}/../scripts/battery")
    [[ "${OUTPUT}" == *'> 40%</span>'* ]]
done

# A battery that does not exist shows nothing
OUTPUT=$(BLOCK_INSTANCE=BAT9 "${SCRIPT_DIR}/../scripts/battery")
[ -z "${OUTPUT}" ]
