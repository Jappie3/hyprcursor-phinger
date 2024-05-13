{
  description = "Most likely the most over engineered cursor theme, but packaged as a Hyprcursor theme.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ] (system: function nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          hyprcursor
          xcur2png
          ripgrep
          jq
          bc
        ];
      };
    });
    packages = forAllSystems (pkgs: {
      default = self.packages.${pkgs.system}.hyprcursor-phinger;
      hyprcursor-phinger = pkgs.callPackage ./nix/package.nix {inherit pkgs;};
    });
    homeManagerModules.default = self.homeManagerModules.hyprcursor-phinger;
    homeManagerModules.hyprcursor-phinger = import ./nix/hm-module.nix self;
  };
}
