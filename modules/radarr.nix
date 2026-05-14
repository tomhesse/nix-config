{
  flake.modules.nixos.radarr = {
    services = {
      radarr = {
        enable = true;
        settings.auth.method = "External";
      };

      oauth2-proxy.nginx.virtualHosts."radarr.shrimphouse.xyz".allowed_groups = [
        "arr_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."radarr.shrimphouse.xyz" = {
        useACMEHost = "radarr.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:7878";
      };
    };

    security.acme.certs."radarr.shrimphouse.xyz".group = "nginx";
  };
}
