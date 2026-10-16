#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
for name in wpctl pactl amixer; do
    ln -s "$SCRIPT_DIR/fixtures/volume/audio" "$WORK/$name"
done
ln -s "$SCRIPT_DIR/xrescat_mock" "$WORK/xrescat"
printf '#!/bin/sh\nexit 0\n' > "$WORK/lsmod"
chmod +x "$WORK/lsmod"
export PATH="$WORK:$PATH"
export AUDIO_STATE="$WORK/state" AUDIO_LOG="$WORK/log"
export AUDIO_BACKEND
unset BLOCK_INSTANCE
for AUDIO_BACKEND in wpctl pactl amixer; do
    printf '05 \n' > "$AUDIO_STATE"
    : > "$AUDIO_LOG"
    output=$(BLOCK_BUTTON='' "$SCRIPT_DIR/../scripts/volume")
    [[ "$output" == *'>S</span>'* && "$output" == *' 05%</span>'* ]]
    for button in 3 4 5 3; do
        output=$(BLOCK_BUTTON=$button "$SCRIPT_DIR/../scripts/volume")
        read -r value muted < "$AUDIO_STATE"
        printf -v expected '%02d%%' "$((10#$value))"
        [[ "$output" == *" $expected</span>" ]]
        if [ -n "$muted" ]; then [[ "$output" == *'>M</span>'* ]]; else [[ "$output" == *'>S</span>'* ]]; fi
        [[ "$output" != *$'\n'* ]]
    done
    [ "$(wc -l < "$AUDIO_LOG")" -eq 4 ]
done
