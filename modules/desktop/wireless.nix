{ config, ... }:
{
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
}
