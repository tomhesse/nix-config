{
  config,
  inputs,
  lib,
  ...
}:
let
  overlay = _final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      inherit (prev) config;
    };
  };
in
{
  options.allowedUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Names of unfree packages that feature modules need. Each module declares its own.";
  };

  config = {
    flake-file.inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
      nixpkgs-lib.follows = "nixpkgs";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake.overlays.unstable = overlay;

    flake.modules.nixos.nixpkgs =
      { lib, ... }:
      {
        nixpkgs = {
          overlays = [ overlay ];

          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.allowedUnfree;
        };
      };
  };
}
