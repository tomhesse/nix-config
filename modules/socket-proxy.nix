{
  flake.modules.nixos.socket-proxy =
    { lib, ... }:
    {
      virtualisation.oci-containers.containers.socket-proxy = {
        image = "ghcr.io/tecnativa/docker-socket-proxy:v0.5.0";
        pull = "missing";

        networks = [ "edge" ];

        volumes = [ "/run/podman/podman.sock:/var/run/docker.sock:ro" ];

        environment = {
          CONTAINERS = "1";
          NETWORKS = "1";
          DISABLE_IPV6 = "1";
        };

        podman.sdnotify = "healthy";

        capabilities.ALL = false;

        extraOptions = [
          "--read-only"
          "--security-opt=no-new-privileges"
          "--health-cmd=wget -q -O - http://127.0.0.1:2375/_ping"
          "--health-interval=10s"
          "--health-timeout=3s"
        ];
      };

      systemd.services.podman-socket-proxy = {
        after = [ "podman.socket" ];
        requires = [ "podman.socket" ];
        serviceConfig.TimeoutStartSec = lib.mkForce 120;
      };
    };
}
