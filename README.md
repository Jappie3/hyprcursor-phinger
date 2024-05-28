# hyprcursor-phinger

This repo contains the Phinger cursor theme packaged in the Hyprcursor format for NixOS. The original repo of the Phinger cursor theme is https://github.com/phisch/phinger-cursors.

Usage: add this flake to your inputs, import the HM module & enable it

```nix
  # first, add the URL to inputs:
  inputs.hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";

  # import the HM module from this flake:
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  # then, enable it:
  programs.hyprcursor-phinger.enable = true;
```

The shell script used in the flake is also provided as a standalone bash script in `phinger-to-hyprcursor.sh`. Once compiled, put the Hyprcursor themes under `~/.local/share/icons/` or `~/.icons`.
