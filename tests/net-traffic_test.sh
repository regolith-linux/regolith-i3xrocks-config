#!/bin/bash

set -Eeux -o pipefail

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}/"

# Test the two button inputs
button=1
export button

../scripts/net-traffic
