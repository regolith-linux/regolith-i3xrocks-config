#!/bin/bash

set -Eeux -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

UMOCKDEV_DIR="${UMOCKDEV_DIR:-}"

[[ -d "${UMOCKDEV_DIR}" ]] || {
    echo "Not running inside umockdev environment!"
    exit 1
}

# Network devices: a libvirt bridge with one guest port, a bridge with a tap
# port, an OpenVPN tun device and a WireGuard device
SYS_NET="${UMOCKDEV_DIR}/sys/class/net"
for dev in wlp59s0 virbr0 vnet0 br0 tap0 tun0 wg0; do
    install -d "${SYS_NET}/${dev}"
done
ln -s ../virbr0 "${SYS_NET}/vnet0/master"
ln -s ../br0 "${SYS_NET}/tap0/master"

export PATH="${SCRIPT_DIR}/fixtures/nm-vpn:${PATH}"
export vpn_label_color="#7B8394" vpn_color="#D8DEE9" font="Source Code Pro Medium 13"
NM_ACTIVE=$(mktemp)
export NM_ACTIVE
trap 'rm -f "${NM_ACTIVE}"' EXIT

WIFI='Home:72b1520d-923c-47f9-9443-59c2d1829c13:802-11-wireless:wlp59s0'
LIBVIRT='virbr0:aefcd86c-6a1a-4b89-b889-42b4fe3ca9f4:bridge:virbr0
vnet0:fa8b1a4f-91de-4a14-9c05-71d4c0233066:tun:vnet0'
BRIDGED_TAP='br0:0b1e2c3d-0000-4000-8000-000000000001:bridge:br0
tap0:0b1e2c3d-0000-4000-8000-000000000002:tap:tap0'

# Only libvirt guests running (#51): no VPN
printf '%s\n%s\n' "${WIFI}" "${LIBVIRT}" > "${NM_ACTIVE}"
[ -z "$("${SCRIPT_DIR}/../scripts/nm-vpn")" ]

# A tap device attached to a bridge is not a VPN either
printf '%s\n%s\n' "${WIFI}" "${BRIDGED_TAP}" > "${NM_ACTIVE}"
[ -z "$("${SCRIPT_DIR}/../scripts/nm-vpn")" ]

# OpenVPN tun device next to libvirt guests
printf '%s\n%s\n%s\n' "${WIFI}" "${LIBVIRT}" 'tun0:9a1d4c55-1111-4222-8333-444455556666:tun:tun0' > "${NM_ACTIVE}"
"${SCRIPT_DIR}/../scripts/nm-vpn" | head -n 1 | grep -q '>tun0</span>$'

# WireGuard connection next to libvirt guests
printf '%s\n%s\n%s\n' "${WIFI}" "${LIBVIRT}" 'Office WG:3c5e7a90-2222-4333-8444-555566667777:wireguard:wg0' > "${NM_ACTIVE}"
"${SCRIPT_DIR}/../scripts/nm-vpn" | head -n 1 | grep -q '>Office WG</span>$'

# A NetworkManager VPN connection is preferred over its tun device
printf '%s\n%s\n%s\n%s\n' "${WIFI}" "${LIBVIRT}" 'Work VPN:5b6c7d8e-3333-4444-8555-666677778888:vpn:wlp59s0' 'tun0:9a1d4c55-1111-4222-8333-444455556666:tun:tun0' > "${NM_ACTIVE}"
"${SCRIPT_DIR}/../scripts/nm-vpn" | head -n 1 | grep -q '>Work VPN</span>$'

# No VPN at all
printf '%s\n' "${WIFI}" > "${NM_ACTIVE}"
[ -z "$("${SCRIPT_DIR}/../scripts/nm-vpn")" ]
