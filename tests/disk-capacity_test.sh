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
