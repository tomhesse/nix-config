{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.desktop.wifi;
in
{
  options.hostSpec.desktop.wifi.enable = mkEnableOption "Enable wifi on the system";

  config = mkIf cfg.enable {
    sops.secrets.wireless = {
      restartUnits = [ "wpa_supplicant.service" ];
    };

    networking.wireless = {
      enable = true;
      fallbackToWPA2 = false;
      secretsFile = config.sops.secrets.wireless.path;
      networks = {
        "Shrimphouse" = {
          pskRaw = "ext:Shrimphouse";
        };
      };
    };
  };
}
