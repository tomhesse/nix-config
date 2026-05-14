{
  flake.modules.nixos.sonarr = {
    services = {
      sonarr = {
        enable = true;
        settings.auth.method = "External";
      };

      oauth2-proxy.nginx.virtualHosts."sonarr.shrimphouse.xyz".allowed_groups = [
        "arr_access@shrimphouse.xyz"
      ];

      nginx.virtualHosts."sonarr.shrimphouse.xyz" = {
        useACMEHost = "sonarr.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:8989";
      };
    };

    security.acme.certs."sonarr.shrimphouse.xyz".group = "nginx";
  };
}
