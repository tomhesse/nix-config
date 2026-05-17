{
  flake.modules.nixos.prometheus = {
    services = {
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        webExternalUrl = "https://prometheus.shrimphouse.xyz";

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              { targets = [ "127.0.0.1:9100" ]; }
            ];
          }
        ];
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
