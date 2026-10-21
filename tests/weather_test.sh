#!/bin/bash

set -Eeux -o pipefail

echo ${BASH_SOURCE[0]}

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
cd "${SCRIPT_DIR}"

# Test if the script runs at all
OUTPUT="$(../scripts/weather)"
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°[CF]\<'

# Test whether it works with specifying Fahrenheit as our weather unit
OUTPUT="$(weather_unit=u ../scripts/weather)"
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°F\<'

# Test whether it supports specifying non-ascii locations
OUTPUT=$(weather_location="São+Paulo" ../scripts/weather)
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°[CF]\<'

# Test whether it supports specifying locations as a compound value
OUTPUT=$(weather_location="London,uk" ../scripts/weather)
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°[CF]\<'

# Changing the output format works too
OUTPUT=$(weather_format=2 ../scripts/weather)
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°[CF].*\d{1,3}(mph|km\/h)\<'

# Changing the output format and the weather unit works
OUTPUT=$(weather_unit=u weather_format=2 ../scripts/weather)
echo "${OUTPUT}" | grep -q -P '[+-]\d{1,3}°[CF].*\d{1,3}mph\<'

# Test whether it reacts to button events
OUTPUT=$(button=1 ../scripts/weather)
echo "${OUTPUT}" | grep -q -P 'i3-msg\scalled\swith\s-q\sexec\sxdg-open\shttps:\/\/wttr.in\/.*'

# Padding whitespace from wttr.in is collapsed and trimmed (#139)
OUTPUT=$(PATH="$(pwd)/fixtures/weather/padded:${PATH}" ../scripts/weather)
[ "${OUTPUT}" == $'<span font_desc="Source Code Pro Medium 13" color="#D8DEE9">\xf0\x9f\x8c\xa4\xef\xb8\x8f +22\xc2\xb0C</span>' ]
OUTPUT=$(PATH="$(pwd)/fixtures/weather/padded:${PATH}" weather_format=2 ../scripts/weather)
[ "${OUTPUT}" == $'<span font_desc="Source Code Pro Medium 13" color="#D8DEE9">\xf0\x9f\x8c\xa4\xef\xb8\x8f \xf0\x9f\x8c\xa1\xef\xb8\x8f+22\xc2\xb0C \xf0\x9f\x8c\xac\xef\xb8\x8f\xe2\x86\x9713km/h</span>' ]

# Test whether we can handle an unknown location properly
PATH="$(pwd)/fixtures/weather/first:${PATH}"
OUTPUT=$(../scripts/weather)
echo "${OUTPUT}" | grep -q $'\u26D4'
