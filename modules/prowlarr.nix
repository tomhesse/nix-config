{
  flake.modules.nixos.prowlarr = {
    services = {
      prowlarr = {
        enable = true;
        settings.auth.method = "External";
      };

      oauth2-proxy.nginx.virtualHosts."prowlarr.shrimphouse.xyz".allowed_groups = [
        "arr_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."prowlarr.shrimphouse.xyz" = {
        useACMEHost = "prowlarr.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:9696";
      };
    };

    security.acme.certs."prowlarr.shrimphouse.xyz".group = "nginx";
  };
}
