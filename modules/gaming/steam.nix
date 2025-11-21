{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.hostSpec.gaming;
in
{
  options.hostSpec.gaming.steam = {
    enable = mkEnableOption "Allow steam installation and enable necessary dependencies.";
  };

  config = mkIf (cfg.enable && cfg.steam.enable) {
    hostSpec.allowedUnfree = [
      "steam"
      "steam-unwrapped"
    ];

    programs.steam.enable = true;
  };
}
