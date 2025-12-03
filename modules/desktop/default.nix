{ lib, ... }:
let
  inherit (lib) mkEnableOption;

  importAll = import ../../lib/importAll.nix { inherit lib; };
in
{
  imports = importAll ./.;

  options.hostSpec.desktop.enable = mkEnableOption "Enable desktop environment on this system.";

  config.hostSpec.allowedUnfree = [
    "obsidian"
  ];
}
