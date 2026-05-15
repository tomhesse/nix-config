{
  flake.modules.nixos.sabnzbd = {
    systemd.tmpfiles.rules = [
      "d /var/tmp/sabnzbd 0755 sabnzbd sabnzbd -"
      "d /var/tmp/sabnzbd/complete 0755 sabnzbd sabnzbd -"
      "d /var/tmp/sabnzbd/incomplete 0750 sabnzbd sabnzbd -"
      "a+ /var/tmp/sabnzbd/complete - - - - default:user:radarr:rX,user:radarr:rX"
      "a+ /var/tmp/sabnzbd/complete - - - - default:user:sonarr:rX,user:sonarr:rX"
    ];

    services = {
      sabnzbd.enable = true;

      oauth2-proxy.nginx.virtualHosts."sabnzbd.shrimphouse.xyz".allowed_groups = [
        "arr_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."sabnzbd.shrimphouse.xyz" = {
        useACMEHost = "sabnzbd.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:8080";
      };
    };

    security.acme.certs."sabnzbd.shrimphouse.xyz".group = "nginx";
  };
}
