{
  flake.modules.nixos.immich =
    { config, ... }:
    let
      domain = "shrimphouse.xyz";

      uid = 411;
    in
    {
      # Needs nixos.authelia on the same host for these options.
      authelia = {
        userAttributes.immich_role.expression = ''"admins" in groups ? "admin" : "user"'';

        oidc = {
          claimsPolicies.immich = {
            id_token = [ "immich_role" ];
            custom_claims.immich_role = {
              name = "immich_role";
              attribute = "immich_role";
            };
          };

          scopes.immich.claims = [ "immich_role" ];

          clients.immich = {
            client_name = "Immich";
            client_secret = "$pbkdf2-sha512$310000$O2aDSK0MK.Dncmz3/fhszA$.8dDBIwARpoBwW7I8oJFEk9FrtgMqX8.owBTX8naT.NtAApdmEoW5Mnv4lVXqe/3uiLjkfOYtRhQp4SxrAygtg";
            public = false;
            authorization_policy = "household";
            claims_policy = "immich";
            consent_mode = "implicit";
            require_pkce = true;
            pkce_challenge_method = "S256";
            token_endpoint_auth_method = "client_secret_basic";
            redirect_uris = [
              "https://photos.${domain}/auth/login"
              "https://photos.${domain}/user-settings"
              "app.immich:///oauth-callback"
            ];
            scopes = [
              "openid"
              "profile"
              "email"
              "immich"
            ];
          };
        };
      };

      virtualisation.oci-containers.containers = {
        immich = {
          image = "ghcr.io/immich-app/immich-server:v3.2.4";

          dependsOn = [
            "immich-machine-learning"
            "immich-postgres"
            "immich-valkey"
          ];

          networks = [ "edge" ];

          user = "${toString uid}:${toString uid}";

          volumes = [
            "/srv/media/immich/originals:/data"
            "/srv/media/immich/encoded-video:/data/encoded-video"
            "/srv/cache/immich/thumbs:/data/thumbs"
          ];

          environment = {
            DB_DATABASE_NAME = "immich";
            DB_HOSTNAME = "immich-postgres";
            DB_USERNAME = "immich";
            IMMICH_MACHINE_LEARNING_URL = "http://immich-machine-learning:3003";
            REDIS_HOSTNAME = "immich-valkey";
            TZ = "Europe/Berlin";
          };

          environmentFiles = [ config.sops.templates."immich-env".path ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.immich.rule" = "Host(`photos.${domain}`)";
          };

          capabilities.ALL = false;

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };

        immich-machine-learning = {
          image = "ghcr.io/immich-app/immich-machine-learning:v3.2.4";

          networks = [ "edge" ];

          user = "${toString uid}:${toString uid}";

          volumes = [ "/srv/cache/immich/models:/cache" ];

          environment.TZ = "Europe/Berlin";

          capabilities.ALL = false;

          extraOptions = [ "--security-opt=no-new-privileges" ];
        };

        immich-postgres = {
          image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3-pgvectors0.2.0";

          networks = [ "edge" ];

          user = "${toString uid}:${toString uid}";

          volumes = [ "/srv/services/immich/postgres:/var/lib/postgresql/data" ];

          environment = {
            POSTGRES_DB = "immich";
            POSTGRES_INITDB_ARGS = "--data-checksums";
            POSTGRES_USER = "immich";
          };

          environmentFiles = [ config.sops.templates."immich-postgres-env".path ];

          podman.sdnotify = "healthy";

          capabilities.ALL = false;

          extraOptions = [
            "--security-opt=no-new-privileges"
            "--shm-size=128m"
            "--health-cmd=/usr/local/bin/healthcheck.sh"
            "--health-interval=10s"
            "--health-start-period=5m"
          ];
        };

        immich-valkey = {
          image = "docker.io/valkey/valkey:9.1.2-alpine";

          networks = [ "edge" ];

          user = "999:1000";

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
        groups.immich.gid = uid;

        users.immich = {
          isSystemUser = true;
          group = "immich";
          inherit uid;
        };
      };

      systemd = {
        services = {
          podman-immich = {
            after = [ "zfs-mount.service" ];

            unitConfig.AssertPathIsMountPoint = [
              "/srv/cache/immich/thumbs"
              "/srv/media/immich/encoded-video"
              "/srv/media/immich/originals"
            ];
          };

          podman-immich-machine-learning = {
            after = [ "zfs-mount.service" ];

            unitConfig.AssertPathIsMountPoint = "/srv/cache/immich/models";
          };

          podman-immich-postgres = {
            after = [ "zfs-mount.service" ];

            unitConfig.AssertPathIsMountPoint = "/srv/services/immich/postgres";
          };
        };

        tmpfiles.rules = [ "d /srv/services/immich/postgres 0700 immich immich -" ];
      };

      sops = {
        secrets."services/immich/db-password" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates = {
          "immich-env" = {
            content = ''
              DB_PASSWORD=${config.sops.placeholder."services/immich/db-password"}
            '';
            restartUnits = [ "podman-immich.service" ];
          };

          "immich-postgres-env" = {
            content = ''
              POSTGRES_PASSWORD=${config.sops.placeholder."services/immich/db-password"}
            '';
            restartUnits = [ "podman-immich-postgres.service" ];
          };
        };
      };
    };
}
