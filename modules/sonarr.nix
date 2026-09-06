{
  flake.modules.nixos.sonarr =
    let
      domain = "shrimphouse.xyz";

      libraries = [
        "/srv/media/video/anime/shows"
        "/srv/media/video/shows"
      ];

      imports = [ "/srv/downloads/complete" ];
    in
    {
      virtualisation.oci-containers.containers.sonarr = {
        image = "lscr.io/linuxserver/sonarr:4.0.19.2979-ls323";

        networks = [ "edge" ];

        volumes = [
          "/srv/services/sonarr:/config"
        ]
        ++ map (path: "${path}:${path}") (libraries ++ imports);

        environment = {
          PUID = "401";
          PGID = "401";
          TZ = "Europe/Berlin";
          SONARR__AUTH__METHOD = "Forms";
          SONARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.sonarr.rule" = "Host(`sonarr.${domain}`)";
          "traefik.http.routers.sonarr.middlewares" = "authelia@docker";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      systemd = {
        services.podman-sonarr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = libraries ++ imports ++ [ "/srv/services/sonarr" ];
        };

        tmpfiles.rules = [ "d /srv/services/sonarr 0700 sonarr sonarr -" ];
      };
    };
}
