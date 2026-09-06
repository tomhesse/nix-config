{
  flake.modules.nixos.sabnzbd =
    let
      domain = "shrimphouse.xyz";

      stages = [
        "/srv/downloads/complete"
        "/srv/downloads/incomplete"
      ];
    in
    {
      virtualisation.oci-containers.containers.sabnzbd = {
        image = "lscr.io/linuxserver/sabnzbd:5.1.2-ls271";

        networks = [ "edge" ];

        volumes = [
          "/srv/services/sabnzbd:/config"
        ]
        ++ map (path: "${path}:${path}") stages;

        environment = {
          PUID = "404";
          PGID = "404";
          UMASK = "002";
          TZ = "Europe/Berlin";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.sabnzbd.rule" = "Host(`sabnzbd.${domain}`)";
          "traefik.http.routers.sabnzbd.middlewares" = "authelia@docker";
        };

        extraOptions = [ "--security-opt=no-new-privileges" ];
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
