{
  flake.modules.nixos.bazarr =
    let
      domain = "shrimphouse.xyz";

      libraries = [
        "/srv/media/video/anime/movies"
        "/srv/media/video/anime/shows"
        "/srv/media/video/movies"
        "/srv/media/video/shows"
      ];
    in
    {
      virtualisation.oci-containers.containers.bazarr = {
        image = "lscr.io/linuxserver/bazarr:v1.6.0-ls362";

        networks = [ "edge" ];

        volumes = [
          "/srv/services/bazarr:/config"
        ]
        ++ map (path: "${path}:${path}") libraries;

        environment = {
          PUID = "405";
          PGID = "405";
          UMASK = "002";
          TZ = "Europe/Berlin";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.bazarr.rule" = "Host(`bazarr.${domain}`)";
          "traefik.http.routers.bazarr.middlewares" = "authelia@docker";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      systemd = {
        services.podman-bazarr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = libraries ++ [ "/srv/services/bazarr" ];
        };

        tmpfiles.rules = [ "d /srv/services/bazarr 0700 bazarr bazarr -" ];
      };
    };
}
