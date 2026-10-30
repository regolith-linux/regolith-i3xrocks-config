#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# cpu-usage <fixture> [args...]: run the blocklet with mpstat reporting <fixture>
run() {
    local fixture=$1
    shift
    PATH="$(pwd)/fixtures/cpu-usage/${fixture}:$(pwd)/fixtures/cpu-usage/bin:${PATH}" ../scripts/cpu-usage "$@"
}

# value colour below the warning threshold (default 50)
OUTPUT=$(run used10)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#D8DEE9'> 10%"

# warning colour from 50%, critical colour from 80%, in full and short text
OUTPUT=$(run used70)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#EBCB8B'> 70%"
echo "${OUTPUT}" | sed -n 2p | grep -q -P "color='#EBCB8B'> 70%"
OUTPUT=$(run used95)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#BF616A'> 95%"

# -w and -c, as the blocklet's help describes
OUTPUT=$(run used70 -w 60 -c 65)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#BF616A'> 70%"
OUTPUT=$(run used70 -w 75 -c 90)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#D8DEE9'> 70%"

# block properties; -w/-c win over them
OUTPUT=$(warning_threshold=75 run used70)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#D8DEE9'> 70%"
OUTPUT=$(warning_threshold=75 run used70 -w 60)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#EBCB8B'> 70%"
OUTPUT=$(warning_color='#123456' run used70)
echo "${OUTPUT}" | head -1 | grep -q -P "color='#123456'> 70%"
