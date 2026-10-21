#!/bin/bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
for name in lsmod wpctl pactl amixer; do
    ln -s "$SCRIPT_DIR/fixtures/microphone/audio" "$WORK/$name"
done
# Answers i3xrocks.mic.mixer with MIC_MIXER when set, otherwise the default.
cat > "$WORK/xrescat" <<'XRESCAT'
#!/bin/bash
if [ "$1" = i3xrocks.mic.mixer ] && [ -n "${MIC_MIXER:-}" ]; then
    echo "$MIC_MIXER"
else
    echo "${2:-}"
fi
XRESCAT
chmod +x "$WORK/xrescat"
export PATH="$WORK:$PATH"
export AUDIO_STATE="$WORK/state" AUDIO_LOG="$WORK/log"
export AUDIO_SERVER AUDIO_JACK MIC_MIXER icon_on=ON icon_mute=MUTED
unset BLOCK_INSTANCE

# check SERVER JACK MIC_MIXER BLOCK_INSTANCE EXPECTED_TOOL [ARGS...]
# The blocklet shows the capture level and mute state, then scrolling and
# right-clicking change them through the expected tool only.
check() {
    AUDIO_SERVER=$1 AUDIO_JACK=$2 MIC_MIXER=$3
    local instance=$4 tool=$5 output button value muted
    shift 5
    printf '05 \n' > "$AUDIO_STATE"
    : > "$AUDIO_LOG"
    output=$(BLOCK_INSTANCE=$instance BLOCK_BUTTON='' "$SCRIPT_DIR/../scripts/microphone" "$@")
    [[ "$output" == *'>ON</span>'* && "$output" == *' 05%</span>' ]]
    for button in 3 4 4 5 3; do
        output=$(BLOCK_INSTANCE=$instance BLOCK_BUTTON=$button "$SCRIPT_DIR/../scripts/microphone" "$@")
        read -r value muted < "$AUDIO_STATE"
        [[ "$output" == *" $(printf '%02d%%' "$((10#$value))")</span>" ]]
        if [ -n "$muted" ]; then [[ "$output" == *'>MUTED</span>'* ]]; else [[ "$output" == *'>ON</span>'* ]]; fi
        [[ "$output" != *$'\n'* ]]
    done
    [ "$value" -eq 10 ] && [ -z "$muted" ]
    [ "$(wc -l < "$AUDIO_LOG")" -eq 5 ]
    if grep -v "^$tool" "$AUDIO_LOG"; then return 1; fi
}

# PipeWire: pactl works but amixer cannot open the pulse device
check pipewire '' '' '' 'wpctl set-'
check pipewire-pulse '' '' '' 'pactl set-source-'
check pulse '' '' '' 'pactl set-source-'
# Plain ALSA and JACK keep using the Capture control of their device
check '' '' '' '' 'amixer -q -D default sset Capture Capture '
check '' 1 '' '' 'amixer -q -D jackplug sset Capture Capture '
# An explicit mixer (xresource or third parameter) or control selects ALSA
check pipewire '' hw:1 '' 'amixer -q -D hw:1 sset Capture Capture '
check pipewire '' '' '' 'amixer -q -D hw:1 sset Capture Capture ' 5 % hw:1
check pipewire '' '' Capture 'amixer -q -D default sset Capture Capture '

# PipeWire's wpctl has no dB reading; pipewire-pulse provides it
AUDIO_SERVER=pipewire AUDIO_JACK='' MIC_MIXER=''
printf '40 \n' > "$AUDIO_STATE"
output=$(BLOCK_BUTTON='' "$SCRIPT_DIR/../scripts/microphone" 3 dB)
[[ "$output" == *'>ON</span>'* && "$output" == *' -23.88dB</span>' ]]
