#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

UMOCKDEV_DIR="${UMOCKDEV_DIR:-}"

[[ -d "${UMOCKDEV_DIR}" ]] || {
    echo "Not running inside umockdev environment!"
    exit 1
}

# meminfo <total kB> <free kB> <swap total kB> <swap free kB>
meminfo() {
    install -d "${UMOCKDEV_DIR}/proc"
    cat >"${UMOCKDEV_DIR}/proc/meminfo" <<MEMINFO
MemTotal:       $1 kB
MemFree:        $2 kB
MemAvailable:   $2 kB
Buffers:               0 kB
Cached:                0 kB
SwapTotal:      $3 kB
SwapFree:       $4 kB
MEMINFO
}

# 16 GiB, 4 GiB free: 75% used, value colour
meminfo 16777216 4194304 2097152 2097152
OUTPUT=$(../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 4.0G<'

# left click opens System Monitor through i3, floating as floating_window
OUTPUT=$(button=1 ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'i3-msg called with -q exec bash -c "(exec -a floating_window /usr/bin/gnome-system-monitor --class=floating_window --show-resources-tab) || exec -a floating_window /usr/bin/gnome-system-monitor --show-resources-tab"'

# 2 GiB free: 87.5% used, warning colour (default 80)
meminfo 16777216 2097152 2097152 2097152
OUTPUT=$(../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#EBCB8B"> 2.0G<'

# 0.5 GiB free: 96.9% used, critical colour (default 95), also as a percentage
meminfo 16777216 524288 2097152 2097152
OUTPUT=$(../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#BF616A"> 0.5G<'
OUTPUT=$(display=used percentage=true ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#BF616A"> 96%<'

# thresholds and colours from block properties
OUTPUT=$(critical_threshold=99 ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#EBCB8B"> 0.5G<'
OUTPUT=$(warning_color="#123456" warning_threshold=50 critical_threshold=99 ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#123456"> 0.5G<'

# swap: colour follows swap use; no swap at all keeps the value colour
meminfo 16777216 8388608 2097152 104857
OUTPUT=$(BLOCK_INSTANCE=swap ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#BF616A"> 0.1G<'
meminfo 16777216 8388608 0 0
OUTPUT=$(BLOCK_INSTANCE=swap ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 0.0G<'

# 4 GiB with 1.5 GiB pinned in tmpfs: Cached includes the Shmem, so
# MemFree + Buffers + Cached would report 3.2G free. Free is MemAvailable.
install -d "${UMOCKDEV_DIR}/proc"
cat >"${UMOCKDEV_DIR}/proc/meminfo" <<MEMINFO
MemTotal:        4194304 kB
MemFree:          204800 kB
MemAvailable:    1784832 kB
Buffers:           51200 kB
Cached:          3072000 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Shmem:           1536000 kB
MEMINFO
OUTPUT=$(../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 1.7G<'
OUTPUT=$(display=used ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 2.3G<'
OUTPUT=$(display=used percentage=true ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 57%<'
OUTPUT=$(warning_threshold=50 ../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#EBCB8B"> 1.7G<'

# kernels without MemAvailable (before 3.14): MemFree + Buffers + Cached
sed -i '/^MemAvailable:/d' "${UMOCKDEV_DIR}/proc/meminfo"
OUTPUT=$(../scripts/memory)
echo "${OUTPUT}" | grep -q -F 'color="#D8DEE9"> 3.2G<'
