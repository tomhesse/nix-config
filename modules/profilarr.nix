{
  flake.modules.nixos.profilarr =
    { config, ... }:
    let
      domain = "shrimphouse.xyz";

      uid = 407;
    in
    {
      # Needs nixos.authelia on the same host for these options.
      authelia.oidc.clients.profilarr = {
        client_name = "Profilarr";
        client_secret = "$pbkdf2-sha512$310000$G9hHaCv6996H5mh59hOpeQ$DpqK9caOIHpImo8d.PcMyOo9/yN3Cr/t31g.PjcoZHzlGqEnLdf5xTTUBaNDMR6mkkPBBN.Cj159YK.RwCeD0A";
        public = false;
        authorization_policy = "admins";
        consent_mode = "implicit";
        token_endpoint_auth_method = "client_secret_post";
        redirect_uris = [ "https://profilarr.${domain}/auth/oidc/callback" ];
        scopes = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
      };

      virtualisation.oci-containers.containers.profilarr = {
        image = "ghcr.io/dictionarry-hub/profilarr:2.2.0";

        networks = [ "edge" ];

        volumes = [ "/srv/services/profilarr:/config" ];

        environment = {
          AUTH = "oidc";
          OIDC_CLIENT_ID = "profilarr";
          OIDC_DISCOVERY_URL = "https://auth.${domain}/.well-known/openid-configuration";
          ORIGIN = "https://profilarr.${domain}";
          PUID = toString uid;
          PGID = toString uid;
          TZ = "Europe/Berlin";
        };

        environmentFiles = [ config.sops.templates."profilarr-env".path ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.profilarr.rule" = "Host(`profilarr.${domain}`)";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      users = {
        groups.profilarr.gid = uid;

        users.profilarr = {
          isSystemUser = true;
          group = "profilarr";
          inherit uid;
        };
      };

      systemd = {
        services.podman-profilarr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = "/srv/services/profilarr";
        };

        tmpfiles.rules = [ "d /srv/services/profilarr 0700 profilarr profilarr -" ];
      };

      sops = {
        secrets."services/profilarr/oidc-client-secret" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."profilarr-env" = {
          content = ''
            OIDC_CLIENT_SECRET=${config.sops.placeholder."services/profilarr/oidc-client-secret"}
          '';
          restartUnits = [ "podman-profilarr.service" ];
        };
      };
    };
}
