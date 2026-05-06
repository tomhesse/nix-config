{
  flake.modules.nixos.paperless =
    { config, ... }:
    {
      services = {
        paperless = {
          enable = true;
          database.createLocally = true;
          configureTika = true;

          settings = {
            PAPERLESS_URL = "https://paperless.shrimphouse.xyz";
            PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
            PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
          };

          environmentFile = config.sops.templates."paperless-env".path;
        };

        nginx.virtualHosts."paperless.shrimphouse.xyz" = {
          useACMEHost = "paperless.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:28981";
          locations."/ws/" = {
            proxyPass = "http://127.0.0.1:28981";
            proxyWebsockets = true;
          };
        };
      };

      sops = {
        secrets = {
          "services/paperless/admin-password" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/paperless/oidc-client-secret" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/paperless/secret-key" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
        };

        templates."paperless-env" = {
          content = ''
            PAPERLESS_ADMIN_USER=admin
            PAPERLESS_ADMIN_PASSWORD=${config.sops.placeholder."services/paperless/admin-password"}
            PAPERLESS_SECRET_KEY=${config.sops.placeholder."services/paperless/secret-key"}
            PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"kanidm","name":"Kanidm","client_id":"paperless","secret":"${
              config.sops.placeholder."services/paperless/oidc-client-secret"
            }","settings":{"server_url":"https://idm.shrimphouse.xyz/oauth2/openid/paperless","token_auth_method":"client_secret_basic"}}]}}
          '';
          restartUnits = [ "paperless-scheduler.service" ];
        };
      };

      security.acme.certs."paperless.shrimphouse.xyz".group = "nginx";
    };
}
