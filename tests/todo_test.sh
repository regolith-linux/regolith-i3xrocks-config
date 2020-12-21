#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# Make sure we can handle 0 with leading space
PATH="$(pwd)/fixtures/todo/first:${PATH}"
OUTPUT=$(../scripts/todo)
echo "${OUTPUT}" | grep -q -P '\>\s{2}0\<'

# Make sure we can handle 1 with leading space
PATH="$(pwd)/fixtures/todo/second:${PATH}"
OUTPUT=$(../scripts/todo)
echo "${OUTPUT}" | grep -q -P '\>\s{2}1\<'

# Make sure we can handle 22 without leading space
PATH="$(pwd)/fixtures/todo/third:${PATH}"
OUTPUT=$(../scripts/todo)
echo "${OUTPUT}" | grep -q -P '\>\s22\<'

# Make sure we can handle 122 without leading space
PATH="$(pwd)/fixtures/todo/fourth:${PATH}"
OUTPUT=$(../scripts/todo)
echo "${OUTPUT}" | grep -q -P '\>\s122\<'
