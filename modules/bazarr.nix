{
  flake.modules.nixos.bazarr = {
    services = {
      bazarr.enable = true;

      oauth2-proxy.nginx.virtualHosts."bazarr.shrimphouse.xyz".allowed_groups = [
        "arr_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."bazarr.shrimphouse.xyz" = {
        useACMEHost = "bazarr.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:6767";
      };
    };

    security.acme.certs."bazarr.shrimphouse.xyz".group = "nginx";
  };
}
