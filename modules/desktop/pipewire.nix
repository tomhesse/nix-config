{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.hostSpec.desktop;
in
{
  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
