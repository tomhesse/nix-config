{
  flake.modules.nixos.grafana =
    { config, ... }:
    {
      services = {
        grafana = {
          enable = true;

          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3001;
              root_url = "https://grafana.shrimphouse.xyz";
            };

            "auth.generic_oauth" = {
              enabled = true;
              name = "Kanidm";
              client_id = "grafana";
              client_secret = "$__file{${config.sops.secrets."services/grafana/oidc-client-secret".path}}";
              scopes = "openid email profile groups";
              login_attribute_path = "preferred_username";
              name_attribute_path = "name";
              email_attribute_path = "email";
              allow_sign_up = true;
              auth_url = "https://idm.shrimphouse.xyz/ui/oauth2";
              token_url = "https://idm.shrimphouse.xyz/oauth2/token";
              api_url = "https://idm.shrimphouse.xyz/oauth2/openid/grafana/userinfo";
              use_pkce = true;
              allowed_groups = "monitoring_users@shrimphouse.xyz";
              signout_redirect_url = "https://idm.shrimphouse.xyz/ui/logout";
            };

          };
        };

        nginx.virtualHosts."grafana.shrimphouse.xyz" = {
          useACMEHost = "grafana.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:3001";
        };
      };

      sops.secrets."services/grafana/oidc-client-secret" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        owner = "grafana";
      };

      systemd.services.grafana = {
        after = [ "kanidm.service" ];
        requires = [ "kanidm.service" ];
      };

      security.acme.certs."grafana.shrimphouse.xyz".group = "nginx";
    };
}
