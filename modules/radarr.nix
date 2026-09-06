{
  flake.modules.nixos.radarr =
    let
      domain = "shrimphouse.xyz";

      libraries = [
        "/srv/media/video/anime/movies"
        "/srv/media/video/movies"
      ];

      imports = [ "/srv/downloads/complete" ];
    in
    {
      virtualisation.oci-containers.containers.radarr = {
        image = "lscr.io/linuxserver/radarr:6.3.0.10514-ls314";

        networks = [ "edge" ];

        volumes = [
          "/srv/services/radarr:/config"
        ]
        ++ map (path: "${path}:${path}") (libraries ++ imports);

        environment = {
          PUID = "402";
          PGID = "402";
          TZ = "Europe/Berlin";
          RADARR__AUTH__METHOD = "Forms";
          RADARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.radarr.rule" = "Host(`radarr.${domain}`)";
          "traefik.http.routers.radarr.middlewares" = "authelia@docker";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      systemd = {
        services.podman-radarr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = libraries ++ imports ++ [ "/srv/services/radarr" ];
        };

        tmpfiles.rules = [ "d /srv/services/radarr 0700 radarr radarr -" ];
      };
    };
}
