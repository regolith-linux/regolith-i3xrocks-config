#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

export PATH="$(pwd)/fixtures/updates:${PATH}"
export LC_ALL=C.UTF-8

OUTPUT=$(../scripts/updates)
echo "${OUTPUT}" | grep -q -F '3/1</span>'
# The default label is nf-md-package_variant_closed from Nerd Fonts 3
if [ ! -f /var/run/reboot-required ]; then
    echo "${OUTPUT}" | grep -q -F $'\U000F03D7'
fi

# Without apt-check (Debian), the default check counts the upgrades a
# simulated dist-upgrade lists, and those from a -security suite
OUTPUT=$(apt_check=/nonexistent PATH="$(pwd)/fixtures/updates-apt-get:${PATH}" ../scripts/updates)
echo "${OUTPUT}" | grep -q -F '4/2</span>'

# Nerd Fonts 3 dropped the legacy Material Design range (U+F500-U+FD46),
# so no blocklet may use it.
if LC_ALL=C grep -rnI -E "$(printf '\357[\224-\264][\200-\277]|\357\265[\200-\206]')" ../scripts; then
    exit 1
fi
