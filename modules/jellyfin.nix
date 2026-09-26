{
  flake.modules.nixos.jellyfin =
    let
      domain = "shrimphouse.xyz";

      uid = 400;

      libraries = [
        "/srv/media/video/anime/movies"
        "/srv/media/video/anime/shows"
        "/srv/media/video/movies"
        "/srv/media/video/shows"
      ];
    in
    {
      virtualisation.oci-containers.containers.jellyfin = {
        image = "docker.io/jellyfin/jellyfin:12.1";

        networks = [ "edge" ];

        user = "${toString uid}:${toString uid}";

        volumes = [
          "/srv/services/jellyfin:/config"
          "/srv/cache/jellyfin:/cache"
        ]
        ++ map (path: "${path}:${path}:ro") libraries;

        environment.JELLYFIN_PublishedServerUrl = "https://jellyfin.${domain}";

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.jellyfin.rule" = "Host(`jellyfin.${domain}`)";
        };

        capabilities.ALL = false;

        extraOptions = [
          "--read-only"
          "--tmpfs=/tmp"
          "--security-opt=no-new-privileges"
        ];
      };

      users = {
        groups.jellyfin.gid = uid;

        users.jellyfin = {
          isSystemUser = true;
          group = "jellyfin";
          inherit uid;
        };
      };

      systemd = {
        services.podman-jellyfin = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = [
            "/srv/services/jellyfin"
            "/srv/cache/jellyfin"
          ];
        };

        tmpfiles.rules = [ "d /srv/services/jellyfin 0700 jellyfin jellyfin -" ];
      };
    };
}
