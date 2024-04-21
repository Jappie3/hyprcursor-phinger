{pkgs, ...}:
pkgs.stdenvNoCC.mkDerivation rec {
  name = "hyprcursor-phinger";
  version = "v2.0";
  src = builtins.fetchurl {
    url = "https://github.com/phisch/phinger-cursors/releases/download/${version}/phinger-cursors-variants.tar.bz2";
    sha256 = "sha256:1cg9siq1xmjb9rw01c88zqzbg4bvsibf5391g7m01yrlswd82p83";
  };
  nativeBuildInputs = with pkgs; [hyprcursor xcur2png];
  phases = ["unpackPhase" "installPhase"];
  unpackPhase = ''
    runHook preUnpack

    # contains multiple directories at the top-level, so default unpackPhase won't work
    tar xf "$src";

    runHook postUnpack
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/cursors/
    mkdir ./phinger_extracted

    for i in $(find -mindepth 1 -maxdepth 1 -type d); do

      local theme="$(echo $i | cut -d/ -f2)"

      if [[ "$theme" == "phinger_extracted" ]]; then
        continue
      fi

      # extract xcursor files
      hyprcursor-util --extract "$i" --output ./phinger_extracted;

      # generate Hyprcursor manifest
      echo -en "
      name = $theme
      description =  Most likely the most over engineered cursor theme.
      version = ${version}
      cursors_directory = hyprcursors
      " > "phinger_extracted/extracted_$theme/manifest.hl"

      # compile Hyprcursor theme
      hyprcursor-util --create "phinger_extracted/extracted_$theme/" --output "$out/cursors"

    done;

    runHook postInstall
  '';
}
