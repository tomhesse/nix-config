{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.hostSpec.gaming;
in
{
  options.hostSpec.gaming.gamescope = {
    enable = mkEnableOption "Enable gamescope on the host.";
  };

  config = mkIf (cfg.enable && cfg.gamescope.enable) {
    programs.gamescope.enable = true;
  };
}
