#!/usr/bin/env bash

# dependencies: hyprcursor-util, rg, jq, wget, bc

version="v2.0"
commit="a7c88739be30a69610b828686a5f00f23095a031"
url="https://github.com/phisch/phinger-cursors/archive/$commit.tar.gz"
out="/tmp/hyprcursor-phinger"

mkdir -p "$out"
pushd "$out"

wget "$url"
tar xzf "$commit.tar.gz" --directory /tmp
cp -r "/tmp/phinger-cursors-$commit/theme" ./


mkdir -p ./hyprcursor/{dark/cursors_dark,light/cursors_light}
CURSORDIR="$(pwd ./hyprcursor)/hyprcursor"

pushd theme

# for every theme listed in cursor-theme.json
for i in $(seq 0 "$(( $(jq '.variants | length' cursor-theme.json) - 1 ))"); do

    currentTheme="$(jq -r ".variants[$i].name" cursor-theme.json)"

    # generate Hyprcursor manifest
    echo -en "
name = phinger-cursors-$currentTheme
description = Most likely the most over engineered cursor theme.
version = ${version}
cursors_directory = cursors_$currentTheme
    " > "$CURSORDIR/$currentTheme/manifest.hl"

    # loop over all the cursors of this theme & create meta.hl for every single one
    for c in $(seq 0 "$(( $(jq ".variants[$i].cursors | length" cursor-theme.json) - 1 ))"); do

    cursorName="$(jq -r ".variants[$i].cursors[$c].name" cursor-theme.json)"

    # cat & rg the first SVG in sprites[] to get the hotspot
    hotspot_x="$(cat "$(jq -r ".variants[$i].cursors[$c].sprites[0].file" cursor-theme.json)" | rg "<rect id=\"center\"" | rg -Po '(?<= x=\")([0-9]*)' || echo 0)"
    hotspot_y="$(cat "$(jq -r ".variants[$i].cursors[$c].sprites[0].file" cursor-theme.json)" | rg "<rect id=\"center\"" | rg -Po '(?<= y=\")([0-9]*)' || echo 0)"

    # get the SVG filename without the [light|dark]/ prefix
    cursorFile="$(jq -r ".variants[$i].cursors[$c].sprites[0].file" cursor-theme.json | cut -d/ -f2)"

    # copy the SVG to CURSORDIR
    mkdir -p "$CURSORDIR/$currentTheme/cursors_$currentTheme/$cursorName"
    cp "$currentTheme/$cursorFile" "$CURSORDIR/$currentTheme/cursors_$currentTheme/$cursorName/"

    # create meta.hl for this SVG under CURSORDIR
    echo -en "resize_algorithm = bilinear
hotspot_x = $(echo "scale=1; $hotspot_x/24" | bc -l | awk '{printf "%.1f\n", $0}')
hotspot_y = $(echo "scale=1; $hotspot_y/24" | bc -l | awk '{printf "%.1f\n", $0}')
define_override = $cursorName
define_size = 24, $cursorFile
    " > "$CURSORDIR/$currentTheme/cursors_$currentTheme/$cursorName/meta.hl"

    done

    # make sure output dir exists
    mkdir -p "$out/cursors/"

    # compile current Hyprcursor theme
    hyprcursor-util --create "$CURSORDIR/$currentTheme/" --output "$out/cursors"

done;

popd
popd

echo -e "\n\nDone - themes are under $out/cursors\n"
