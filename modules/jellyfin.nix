{
  flake.modules.nixos.jellyfin = {
    services = {
      jellyfin.enable = true;

      nginx.virtualHosts."jellyfin.shrimphouse.xyz" = {
        useACMEHost = "jellyfin.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:8096";
        locations."/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
    };

    security.acme.certs."jellyfin.shrimphouse.xyz".group = "nginx";
  };
}
