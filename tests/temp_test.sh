#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

declare -a FIXTURES
FIXTURES=("first" "second" "third" "fourth")

for fixture in "${FIXTURES[@]}"; do
  PATH="$(pwd)/fixtures/temp/${fixture}:${PATH}"
  OUTPUT=$(../scripts/temp)
  echo "${OUTPUT}" | grep -q "40"
done

# Without Core, Tdie or Tctl readings, the CPU chip or a CPU label is used
OUTPUT=$(PATH="$(pwd)/fixtures/temp/raspberry-pi:${PATH}" ../scripts/temp)
echo "${OUTPUT}" | grep -q " 47°C"
OUTPUT=$(PATH="$(pwd)/fixtures/temp/thinkpad-cpu-label:${PATH}" ../scripts/temp)
echo "${OUTPUT}" | grep -q " 41°C"

# With no CPU temperature at all, the blocklet prints nothing and succeeds
OUTPUT=$(PATH="$(pwd)/fixtures/temp/no-cpu-sensor:${PATH}" ../scripts/temp)
[ -z "${OUTPUT}" ]
OUTPUT=$(PATH="$(pwd)/fixtures/temp/no-sensors:${PATH}" ../scripts/temp)
[ -z "${OUTPUT}" ]
