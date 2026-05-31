{
  flake.modules.nixos.wireless =
    { config, ... }:
    {
      sops.secrets."wireless/Shrimphouse" = { };

      sops.templates.wireless = {
        content = ''
          psk_Shrimphouse=${config.sops.placeholder."wireless/Shrimphouse"}
        '';
        restartUnits = [ "wpa_supplicant.service" ];
        owner = "wpa_supplicant";
      };

      systemd.network.networks."20-wireless" = {
        matchConfig.Type = "wlan";
        networkConfig = {
          DHCP = "yes";
          UseDomains = "yes";
        };
      };

      networking.wireless = {
        enable = true;
        fallbackToWPA2 = false;
        secretsFile = config.sops.templates.wireless.path;
        networks."Shrimphouse".pskRaw = "ext:psk_Shrimphouse";
      };
    };
}
