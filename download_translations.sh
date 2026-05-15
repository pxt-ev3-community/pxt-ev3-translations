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
ev3/storage-jsdoc-strings.json
ev3/storage-strings.json
ev3/broadcast-jsdoc-strings.json
ev3/broadcast-strings.json
ev3/nxt-light-sensor-jsdoc-strings.json
ev3/nxt-light-sensor-strings.json
"

for lang in $LANGUAGES
do
    mkdir -p $lang/ev3
    mkdir -p crowdin-original/$lang/ev3

    for file in $FILES
    do
        # Take the old crowdin file as a reference
        if [ -e crowdin-original/$lang/$file ]
        then cp crowdin-original/$lang/$file tmp_old.json
        else echo '{}' > tmp_old.json
        fi

        # Download latest crowdin file and pretty-print
        wget "https://makecode.com/api/translations?lang=$lang&filename=$file" -O tmp.json
        jq . tmp.json > tmp_new.json
        cp tmp_new.json crowdin-original/$lang/$file

        # Do three-way merge with jq.
        # Update local .json file only if tmp_new differs from tmp_old,
        # i.e. only when there has been a change on crowdin.
        jq -n '
          reduce (inputs | paths(scalars)) as $path (
            input;
            if (([inputs][0] | getpath($path)) != ([inputs][1] | getpath($path)))
            then setpath($path; [inputs][1] | getpath($path))
            else .
            end
          )
        ' $lang/$file tmp_old.json tmp_new.json > tmp_updated.json

        # Mangle leading/trailing spaces because pxt seems to strip them otherwise.
        jq 'walk(if type == "string" then sub("^ "; "\u200D ") | sub(" $"; " \u200D") else . end)' tmp_updated.json > $lang/$file

        rm tmp*.json
        sleep 0.1
    done
done

