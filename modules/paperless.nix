{
  flake.modules.nixos.paperless =
    { config, ... }:
    let
      domain = "shrimphouse.xyz";

      uid = 409;
    in
    {
      virtualisation.oci-containers.containers = {
        paperless = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.15";

          dependsOn = [
            "paperless-gotenberg"
            "paperless-tika"
            "paperless-valkey"
          ];

          networks = [ "edge" ];

          user = "${toString uid}:${toString uid}";

          volumes = [
            "/srv/documents/paperless:/usr/src/paperless/media"
            "/srv/services/paperless:/usr/src/paperless/data"
          ];

          environment = {
            PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
            PAPERLESS_REDIS = "redis://paperless-valkey:6379";
            PAPERLESS_TIKA_ENABLED = "1";
            PAPERLESS_TIKA_ENDPOINT = "http://paperless-tika:9998";
            PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";
            PAPERLESS_URL = "https://paperless.${domain}";
            TZ = "Europe/Berlin";
          };

          environmentFiles = [ config.sops.templates."paperless-env".path ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.paperless.rule" = "Host(`paperless.${domain}`)";
          };

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };

        paperless-gotenberg = {
          image = "docker.io/gotenberg/gotenberg:8.25";

          networks = [ "edge" ];

          cmd = [
            "gotenberg"
            "--chromium-disable-javascript=true"
            "--chromium-allow-list=file:///tmp/.*"
          ];

          capabilities.ALL = false;

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };

        paperless-tika = {
          image = "docker.io/apache/tika:4.0.0-1-full";

          networks = [ "edge" ];

          capabilities.ALL = false;

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };

        paperless-valkey = {
          image = "docker.io/valkey/valkey:8.1.10-alpine";

          networks = [ "edge" ];

          cmd = [
            "valkey-server"
            "--save"
            ""
          ];

          capabilities.ALL = false;

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };
      };

      users = {
        groups.paperless.gid = uid;

        users.paperless = {
          isSystemUser = true;
          group = "paperless";
          inherit uid;
        };
      };

      systemd = {
        services.podman-paperless = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = [
            "/srv/documents/paperless"
            "/srv/services/paperless"
          ];
        };

        tmpfiles.rules = [
          "z /srv/documents/paperless 0700 paperless paperless -"
          "d /srv/services/paperless 0700 paperless paperless -"
        ];
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
            PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"authelia","name":"Authelia","client_id":"paperless","secret":"${
              config.sops.placeholder."services/paperless/oidc-client-secret"
            }","settings":{"server_url":"https://auth.${domain}","token_auth_method":"client_secret_basic"}}]}}
          '';
          restartUnits = [ "podman-paperless.service" ];
        };
      };
    };
}
