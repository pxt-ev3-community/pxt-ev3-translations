#!/bin/bash

set -e
set -x

LANGUAGES="de ja ru zh-CN fr fi"
FILES="
strings.json
ev3/target-strings.json
ev3/bundled-strings.json
ev3/sim-strings.json
ev3/ev3-jsdoc-strings.json
ev3/ev3-strings.json
ev3/base-jsdoc-strings.json
ev3/base-strings.json
ev3/core-jsdoc-strings.json
ev3/core-strings.json
ev3/screen-jsdoc-strings.json
ev3/screen-strings.json
ev3/music-jsdoc-strings.json
ev3/music-strings.json
ev3/color-sensor-jsdoc-strings.json
ev3/color-sensor-strings.json
ev3/touch-sensor-jsdoc-strings.json
ev3/touch-sensor-strings.json
ev3/ultrasonic-sensor-jsdoc-strings.json
ev3/ultrasonic-sensor-strings.json
ev3/gyro-sensor-jsdoc-strings.json
ev3/gyro-sensor-strings.json
ev3/infrared-sensor-jsdoc-strings.json
ev3/infrared-sensor-strings.json
"

for lang in $LANGUAGES
do
    mkdir -p $lang/ev3
    for file in $FILES
    do
        wget "https://makecode.com/api/translations?lang=$lang&filename=$file" -O tmp.json

        # Mangle leading/trailing spaces because pxt seems to strip them otherwise.
        jq 'walk(if type == "string" then sub("^ "; "\u200D ") | sub(" $"; " \u200D") else . end)' tmp.json > $lang/$file
        rm tmp.json
        sleep 0.1
    done
done

