{
  flake.modules.nixos.prowlarr =
    let
      domain = "shrimphouse.xyz";

      uid = 403;
    in
    {
      virtualisation.oci-containers.containers.prowlarr = {
        image = "lscr.io/linuxserver/prowlarr:2.5.2.5491-ls158";

        networks = [ "edge" ];

        volumes = [ "/srv/services/prowlarr:/config" ];

        environment = {
          PUID = toString uid;
          PGID = toString uid;
          TZ = "Europe/Berlin";
          PROWLARR__AUTH__METHOD = "Forms";
          PROWLARR__AUTH__REQUIRED = "DisabledForLocalAddresses";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.prowlarr.rule" = "Host(`prowlarr.${domain}`)";
          "traefik.http.routers.prowlarr.middlewares" = "authelia@docker";
          "traefik.http.routers.prowlarr-health.rule" = "Host(`prowlarr.${domain}`) && Path(`/ping`)";
          "traefik.http.routers.prowlarr-health.entrypoints" = "websecure";
          "traefik.http.routers.prowlarr-health.middlewares" = "ha-only@docker";
          "traefik.http.routers.prowlarr-health.priority" = "100";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      users = {
        groups.prowlarr.gid = uid;

        users.prowlarr = {
          isSystemUser = true;
          group = "prowlarr";
          inherit uid;
        };
      };

      systemd = {
        services.podman-prowlarr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = "/srv/services/prowlarr";
        };

        tmpfiles.rules = [ "d /srv/services/prowlarr 0700 prowlarr prowlarr -" ];
      };
    };
}
