#!/bin/bash

set -Eeux -o pipefail

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}/"

# Regular syntax
[ "2" -eq "$(../scripts/net-traffic | ag -o '(?<=\>\s)(\d{1,4}|\d{1,3},?\d{0,1}?)[GMKB](?=\<)' | wc -l)" ]

# up, down, total as RT
for summary in up down total ; do
    [ "1" -eq "$(RT=${summary} ../scripts/net-traffic | ag -o '(?<=\>\s)(\d{1,4}|\d{1,3},?\d{0,1}?)[GMKB](?=\<)' | wc -l)" ]
done

# Test the two button inputs
button=1
export button

../scripts/net-traffic
