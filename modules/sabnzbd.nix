{
  flake.modules.nixos.sabnzbd =
    let
      domain = "shrimphouse.xyz";

      uid = 404;

      stages = [
        "/srv/downloads/complete"
        "/srv/downloads/incomplete"
      ];
    in
    {
      virtualisation.oci-containers.containers.sabnzbd = {
        image = "lscr.io/linuxserver/sabnzbd:5.1.3-ls274";

        networks = [ "edge" ];

        volumes = [
          "/srv/services/sabnzbd:/config"
        ]
        ++ map (path: "${path}:${path}") stages;

        environment = {
          PUID = toString uid;
          PGID = toString uid;
          UMASK = "002";
          TZ = "Europe/Berlin";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.sabnzbd.rule" = "Host(`sabnzbd.${domain}`)";
          "traefik.http.routers.sabnzbd.middlewares" = "authelia@docker";
          "traefik.http.routers.sabnzbd-health.rule" =
            "Host(`sabnzbd.${domain}`) && Path(`/api`) && Query(`mode`, `version`)";
          "traefik.http.routers.sabnzbd-health.entrypoints" = "websecure";
          "traefik.http.routers.sabnzbd-health.middlewares" = "ha-only@docker";
          "traefik.http.routers.sabnzbd-health.priority" = "100";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
      };

      users = {
        groups.sabnzbd.gid = uid;

        users.sabnzbd = {
          isSystemUser = true;
          group = "sabnzbd";
          inherit uid;
        };
      };

      systemd = {
        services.podman-sabnzbd = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = stages ++ [ "/srv/services/sabnzbd" ];
        };

        tmpfiles.rules = [ "d /srv/services/sabnzbd 0700 sabnzbd sabnzbd -" ];
      };
    };
}
