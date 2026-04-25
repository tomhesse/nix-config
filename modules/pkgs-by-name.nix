{ inputs, withSystem, ... }:
let
  overlay =
    _final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:
      {
        local = config.packages;
      }
    );
in
{
  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  flake-file.inputs.pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

  perSystem.pkgsDirectory = ../packages;

  flake.overlays.local = overlay;

  flake.modules.nixos.local-packages = {
    nixpkgs.overlays = [ overlay ];
  };
}
