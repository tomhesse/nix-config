{
  flake.modules.nixos.alertmanager =
    { config, ... }:
    {
      services = {
        prometheus.alertmanager = {
          enable = true;
          listenAddress = "127.0.0.1";
          webExternalUrl = "https://alertmanager.shrimphouse.xyz";
          environmentFile = config.sops.templates."alertmanager-env".path;
          configuration = {
            global = {
              smtp_hello = "alertmanager.shrimphouse.xyz";
            };
            route = {
              receiver = "scaleway";
            };
            receivers = [
              {
                name = "scaleway";
                email_configs = [
                  {
                    to = "admin@shrimphouse.xyz";
                    from = "alertmanager@mail.shrimphouse.xyz";
                    smarthost = "smtp.tem.scaleway.com:465";
                    auth_username = "608deeb4-b226-44f7-bb38-4354d8029c7e";
                    auth_password = "$SMTP_PASSWORD";
                    require_tls = false;
                  }
                ];
              }
            ];
          };
        };

        oauth2-proxy.nginx.virtualHosts."alertmanager.shrimphouse.xyz".allowed_groups = [
          "monitoring_users@shrimphouse.xyz"
        ];

        nginx.virtualHosts."alertmanager.shrimphouse.xyz" = {
          useACMEHost = "alertmanager.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:9093";
        };
      };

      security.acme.certs."alertmanager.shrimphouse.xyz".group = "nginx";

      sops = {
        secrets."services/alertmanager/smtp-password" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."alertmanager-env" = {
          content = ''
            SMTP_PASSWORD=${config.sops.placeholder."services/alertmanager/smtp-password"}
          '';
          restartUnits = [ "alertmanager.service" ];
        };
      };
    };
}
