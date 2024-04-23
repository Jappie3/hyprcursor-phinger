#!/usr/bin/env bash

version="v2.0"
url="https://github.com/phisch/phinger-cursors/releases/download/$version/phinger-cursors-variants.tar.bz2";
tarball="phinger-$version.tar.bz2"
out="/tmp/hyprcursor-phinger"

mkdir -p "$out"
pushd "$out"

wget -O "$tarball" "$url"
tar xf "$tarball"
rm "$tarball"

mkdir -p "$out/cursors/" "$out/extracted/"

for i in $(find -mindepth 1 -maxdepth 1 -type d); do

    theme="$(echo $i | cut -d/ -f2)"

    if [[ "$theme" == "extracted" ]] || [[ "$theme" == "cursors" ]]; then
        continue
    fi

    # extract xcursor files
    hyprcursor-util --extract "$i" --output "$out/extracted/"

    # generate Hyprcursor manifest
    echo -en "
    name = $theme
    description =  Most likely the most over engineered cursor theme.
    version = ${version}
    cursors_directory = hyprcursors
    " > "$out/extracted/extracted_$theme/manifest.hl"

    # compile Hyprcursor theme
    hyprcursor-util --create "$out/extracted/extracted_$theme/" --output "$out/cursors"

done;

popd

echo -e "\n\nDone - themes are under $out/cursors\n"
