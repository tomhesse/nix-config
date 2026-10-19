{
  flake.modules.nixos.networkmanager =
    { config, ... }:
    let
      stateDirectories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/NetworkManager"
      ];
    in
    {
      sops.secrets."wireless/Shrimphouse" = { };

      sops.templates.networkmanager = {
        content = ''
          PSK_SHRIMPHOUSE=${config.sops.placeholder."wireless/Shrimphouse"}
        '';
        restartUnits = [ "NetworkManager-ensure-profiles.service" ];
      };

      hardware.facter.detected.dhcp.enable = false;

      networking.networkmanager = {
        enable = true;
        ensureProfiles = {
          environmentFiles = [ config.sops.templates.networkmanager.path ];
          profiles.Shrimphouse = {
            connection = {
              id = "Shrimphouse";
              type = "wifi";
            };
            wifi.ssid = "Shrimphouse";
            wifi-security = {
              key-mgmt = "sae";
              psk = "$PSK_SHRIMPHOUSE";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
          };
        };
      };

      environment.persistence."/persistent".directories = [
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        "/var/lib/NetworkManager"
      ];

      systemd.services.NetworkManager.unitConfig.RequiresMountsFor = stateDirectories;
    };
}
