#!/bin/bash

set -Eeux -o pipefail

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}/"

SYS_PREFIX="/sys/class/net"
declare -a NET_DIRS=(
    "${SYS_PREFIX}/eth0/statistics"
    "${SYS_PREFIX}/wlan0/statistics"
    "${SYS_PREFIX}/wlan0/wireless"
)

UMOCKDEV_DIR="${UMOCKDEV_DIR:-}"

[[ -d "${UMOCKDEV_DIR}" ]] || {
    echo "Not running inside umockdev environment!"
    exit 1
}

for dir in "${NET_DIRS[@]}"; do
    install -d "${UMOCKDEV_DIR}/${dir}"
done

# eth0, 1KB of RX/TX
BYTES="1024"
BLOCK_INSTANCE="eth0"
export BLOCK_INSTANCE

for b in rx tx; do
    echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

sleep 1

for b in rx tx; do
    # Need to multiple by 6 here in order to get exactly 1KB of traffic
    echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

sleep 5

[ "2" -eq "$(ag -o '\>\s{2}1[,.]0K\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]

# eth0, 1000B of RX/TX
BYTES="1000"
BLOCK_INSTANCE="eth0"
export BLOCK_INSTANCE

for b in rx tx; do
    echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

sleep 1

for b in rx tx; do
    # Need to multiple by 6 here in order to get exactly 1KB of traffic
    echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

sleep 5

[ "2" -eq "$(ag -o '\>\s1000B\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]

# eth0, see whether we measure M correctly in RX/TX
BYTES="1024"
BLOCK_INSTANCE="eth0"
export BLOCK_INSTANCE

for b in rx tx; do
    echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

sleep 1

for b in rx tx; do
    # Need to multiple by 6 here in order to get exactly 1KB of traffic
    echo "${BYTES}*1024*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

sleep 5

[ "2" -eq "$(ag -o '\>\s{2}1[.,]2M\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]

# wlan0, 1KB of RX/TX
BYTES="1024"
BLOCK_INSTANCE="wlan0"
export BLOCK_INSTANCE

for b in rx tx; do
    echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

sleep 1

for b in rx tx; do
    # Need to multiple by 6 here in order to get exactly 1KB of traffic
    echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

sleep 5

[ "2" -eq "$(ag -o '\>\s{2}1[.,]0K\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]
# grep -q $'\uf5a9' /tmp/net-traffic-${BLOCK_INSTANCE}-output

# eth0, see whether we output only one direction correctly
for direction in up down; do
    BYTES="1024"
    BLOCK_INSTANCE="eth0"
    export BLOCK_INSTANCE

    for b in rx tx; do
        echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
    done

    RT="${direction}" ../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

    sleep 1

    for b in rx tx; do
        # Need to multiple by 6 here in order to get exactly 1KB of traffic
        echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
    done

    sleep 5

    [ "1" -eq "$(ag -o '\>\s{2}1[.,]0K\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]
done

# eth0, see whether we can only report totals
BYTES="1024"
BLOCK_INSTANCE="eth0"
export BLOCK_INSTANCE

for b in rx tx; do
    echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

RT="total" ../scripts/net-traffic >"/tmp/net-traffic-${BLOCK_INSTANCE}-output" &

sleep 1

for b in rx tx; do
    # Need to multiple by 6 here in order to get exactly 1KB of traffic
    echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/${BLOCK_INSTANCE}/statistics/${b}_bytes"
done

sleep 5

[ "1" -eq "$(ag -o '\>\s{2}2[.,]0K\<' /tmp/net-traffic-${BLOCK_INSTANCE}-output | wc -l)" ]

# eth0, see whether we select the right interface, traffic is irrelevant
# We shouldn't hard-code the device because it is supposed get this back from the ip mock
unset BLOCK_INSTANCE
BYTES="1024"

for mock in "first" "second"; do
    PATH="${PWD}/fixtures/net-traffic/${mock}:${PATH}"
    export PATH

    for b in rx tx; do
        echo "${BYTES}" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/eth0/statistics/${b}_bytes"
    done

    ../scripts/net-traffic >"/tmp/net-traffic-eth0-output" &

    sleep 1

    for b in rx tx; do
        echo "${BYTES}*6" | bc >"${UMOCKDEV_DIR}/${SYS_PREFIX}/eth0/statistics/${b}_bytes"
    done

    sleep 5

    [ "2" -eq "$(ag -o '\>\s{2}1[.,]0K\<' /tmp/net-traffic-eth0-output | wc -l)" ]
done
