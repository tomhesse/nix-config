{
  flake.modules.nixos.seerr =
    let
      domain = "shrimphouse.xyz";
    in
    {
      virtualisation.oci-containers.containers.seerr = {
        image = "ghcr.io/seerr-team/seerr:v3.4.1";

        networks = [ "edge" ];

        user = "408:408";

        volumes = [ "/srv/services/seerr:/app/config" ];

        environment = {
          LOG_LEVEL = "info";
          TZ = "Europe/Berlin";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.seerr.rule" = "Host(`requests.${domain}`)";
        };

        capabilities.ALL = false;

        extraOptions = [
          "--init"
          "--security-opt=no-new-privileges"
        ];
      };

      systemd = {
        services.podman-seerr = {
          after = [ "zfs-mount.service" ];

          unitConfig.AssertPathIsMountPoint = "/srv/services/seerr";
        };

        tmpfiles.rules = [ "d /srv/services/seerr 0700 seerr seerr -" ];
      };
    };
}
