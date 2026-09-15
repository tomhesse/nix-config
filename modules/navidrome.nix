{
  flake.modules.nixos.navidrome =
    { config, ... }:
    let
      domain = "shrimphouse.xyz";

      uid = 406;
    in
    {
      virtualisation.oci-containers.containers.navidrome = {
        image = "ghcr.io/navidrome/navidrome:0.64.0";

        networks = [ "edge" ];

        user = "${toString uid}:${toString uid}";

        volumes = [
          "/srv/services/navidrome:/data"
          "/srv/media/music:/music:ro"
        ];

        environment = {
          ND_BASEURL = "https://music.${domain}";
          ND_ENABLEDOWNLOADS = "false";
          TZ = "Europe/Berlin";
        };

        environmentFiles = [ config.sops.templates."navidrome-env".path ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.navidrome.rule" = "Host(`music.${domain}`)";
        };

        capabilities.ALL = false;

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      users = {
        groups.navidrome.gid = uid;

        users.navidrome = {
          isSystemUser = true;
          group = "navidrome";
          inherit uid;
        };
      };

      systemd = {
        services.podman-navidrome = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = [
            "/srv/media/music"
            "/srv/services/navidrome"
          ];
        };

        tmpfiles.rules = [ "d /srv/services/navidrome 0700 navidrome navidrome -" ];
      };

      sops = {
        secrets = {
          "services/navidrome/lastfm-api-key" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };

          "services/navidrome/lastfm-api-secret" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };

          "services/navidrome/password-encryption-key" = {
            sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
          };
        };

        templates."navidrome-env" = {
          content = ''
            ND_LASTFM_APIKEY=${config.sops.placeholder."services/navidrome/lastfm-api-key"}
            ND_LASTFM_SECRET=${config.sops.placeholder."services/navidrome/lastfm-api-secret"}
            ND_PASSWORDENCRYPTIONKEY=${config.sops.placeholder."services/navidrome/password-encryption-key"}
          '';
          restartUnits = [ "podman-navidrome.service" ];
        };
      };
    };
}
