# TODO: remove overlay and import once nixpkgs#523085 is merged
{ inputs, ... }:
let
  overlay = _final: prev: {
    inherit (inputs.nixpkgs-musivault.legacyPackages.${prev.stdenv.hostPlatform.system}) musivault;
  };
in
{
  flake.overlays.musivault = overlay;

  flake.modules.nixos.musivault =
    { config, ... }:
    {
      nixpkgs.overlays = [ overlay ];
      imports = [ "${inputs.nixpkgs-musivault}/nixos/modules/services/web-apps/musivault.nix" ];

      services = {
        musivault = {
          enable = true;

          environment = {
            ADMIN_EMAIL = "admin@shrimphouse.xyz";
            ADMIN_USERNAME = "admin";
            FRONTEND_URL = "https://musivault.shrimphouse.xyz";
            MONGO_URI = "mongodb://127.0.0.1:27017/musivault";
            OIDC_CLIENT_ID = "musivault";
            OIDC_ISSUER = "https://idm.shrimphouse.xyz/oauth2/openid/musivault";
            OIDC_PROVIDER_NAME = "Kanidm";
            OIDC_REDIRECT_URI = "https://musivault.shrimphouse.xyz/auth/callback";
          };

          nginxVirtualHost = "musivault.shrimphouse.xyz";

          environmentFiles = [ config.sops.templates."musivault-env".path ];
        };

        nginx.virtualHosts."musivault.shrimphouse.xyz" = {
          useACMEHost = "musivault.shrimphouse.xyz";
          forceSSL = true;
        };
      };

      sops = {
        secrets = {
          "services/musivault/admin-password" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/musivault/discogs-key" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/musivault/discogs-pat" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/musivault/discogs-secret" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/musivault/oidc-client-secret" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
          "services/musivault/session-secret" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
        };

        templates."musivault-env" = {
          content = ''
            ADMIN_PASSWORD=${config.sops.placeholder."services/musivault/admin-password"}
            DISCOGS_KEY=${config.sops.placeholder."services/musivault/discogs-key"}
            DISCOGS_PAT=${config.sops.placeholder."services/musivault/discogs-pat"}
            DISCOGS_SECRET=${config.sops.placeholder."services/musivault/discogs-secret"}
            OIDC_CLIENT_SECRET=${config.sops.placeholder."services/musivault/oidc-client-secret"}
            SESSION_SECRET=${config.sops.placeholder."services/musivault/session-secret"}
          '';
          restartUnits = [ "musivault.service" ];
        };
      };

      systemd.services.musivault = {
        after = [ "mongodb.service" ];
        requires = [ "mongodb.service" ];
      };

      security.acme.certs."musivault.shrimphouse.xyz".group = "nginx";
    };
}
