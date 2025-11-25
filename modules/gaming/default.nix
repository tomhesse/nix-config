{ lib, ... }:
let
  inherit (lib) mkEnableOption;

  importAll = import ../../lib/importAll.nix { inherit lib; };
in
{
  imports = importAll ./.;

  options.hostSpec.gaming.enable = mkEnableOption "Enable gaming configuration on this system.";

  config.hostSpec.allowedUnfree = [
    "steam"
    "steam-unwrapped"
    "osu-lazer-bin"
  ];

}
