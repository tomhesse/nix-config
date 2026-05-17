{
  flake.modules.nixos.prometheus = {
    services = {
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        webExternalUrl = "prometheus.shrimphouse.xyz";
      };

      oauth2-proxy.nginx.virtualHosts."prometheus.shrimphouse.xyz".allowed_groups = [
        "monitoring_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."prometheus.shrimphouse.xyz" = {
        useACMEHost = "prometheus.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:9090";
      };
    };

    security.acme.certs."prometheus.shrimphouse.xyz".group = "nginx";
  };
}
