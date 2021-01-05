#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

declare -a FIXTURES
FIXTURES=( "first" "second" "third" )

for fixture in "${FIXTURES[@]}"
do
    PATH="$(pwd)/fixtures/temp/${fixture}:${PATH}"
    OUTPUT=$(../scripts/temp)
    echo "${OUTPUT}" | grep -q "40"
done
