{ lib, ... }:
{
  flake.modules.nixos =
    let
      domain = "shrimphouse.xyz";

      images = {
        radarr = "lscr.io/linuxserver/radarr:6.3.0.10514-ls314";
        sonarr = "lscr.io/linuxserver/sonarr:4.0.19.2979-ls323";
      };

      mkArr =
        {
          app,
          image,
          libraries,
          uid,
        }:
        let
          mounts = libraries ++ [ "/srv/downloads/complete" ];
        in
        {
          virtualisation.oci-containers.containers.${app} = {
            inherit image;

            networks = [ "edge" ];

            volumes = [
              "/srv/services/${app}:/config"
            ]
            ++ map (path: "${path}:${path}") mounts;

            environment = {
              PUID = toString uid;
              PGID = toString uid;
              UMASK = "002";
              TZ = "Europe/Berlin";
              "${lib.toUpper app}__AUTH__METHOD" = "Forms";
              "${lib.toUpper app}__AUTH__REQUIRED" = "DisabledForLocalAddresses";
            };

            labels = {
              "traefik.enable" = "true";
              "traefik.http.routers.${app}.rule" = "Host(`${app}.${domain}`)";
              "traefik.http.routers.${app}.middlewares" = "authelia@docker";
            };

            extraOptions = [ "--security-opt=no-new-privileges" ];
          };

          users = {
            groups.${app}.gid = uid;

            users.${app} = {
              isSystemUser = true;
              group = app;
              inherit uid;
            };
          };

          systemd = {
            services."podman-${app}" = {
              after = [ "zfs-mount.service" ];

              unitConfig.AssertPathIsMountPoint = mounts ++ [ "/srv/services/${app}" ];
            };

            tmpfiles.rules = [ "d /srv/services/${app} 0700 ${app} ${app} -" ];
          };
        };
    in
    {
      radarr = mkArr {
        app = "radarr";
        image = images.radarr;
        libraries = [
          "/srv/media/video/anime/movies"
          "/srv/media/video/movies"
        ];
        uid = 402;
      };

      sonarr = mkArr {
        app = "sonarr";
        image = images.sonarr;
        libraries = [
          "/srv/media/video/anime/shows"
          "/srv/media/video/shows"
        ];
        uid = 401;
      };
    };
}
