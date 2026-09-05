{
  flake.modules.nixos.traefik =
    { config, pkgs, ... }:
    let
      domain = "shrimphouse.xyz";

      staticConfig = (pkgs.formats.yaml { }).generate "traefik.yml" {
        global.checkNewVersion = false;

        accessLog = { };

        api = { };

        ping = { };

        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };

          websecure = {
            address = ":443";
            asDefault = true;

            http.tls = {
              certResolver = "letsencrypt";
              domains = [ { main = "*.${domain}"; } ];
            };
          };
        };

        providers.docker = {
          endpoint = "tcp://socket-proxy:2375";
          exposedByDefault = false;
          network = "edge";
        };

        certificatesResolvers.letsencrypt.acme = {
          email = "hostmaster@${domain}";
          storage = "/data/acme.json";

          dnsChallenge = {
            provider = "scaleway";
            resolvers = [
              "1.1.1.1:53"
              "9.9.9.9:53"
            ];
          };
        };
      };
    in
    {
      virtualisation.oci-containers.containers.traefik = {
        image = "docker.io/traefik:v3.7.13";

        dependsOn = [ "socket-proxy" ];
        networks = [ "edge" ];

        ports = [
          "80:80"
          "443:443"
        ];

        volumes = [
          "${staticConfig}:/etc/traefik/traefik.yml:ro"
          "/srv/services/traefik:/data"
        ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.dashboard.rule" = "Host(`traefik.${domain}`)";
          "traefik.http.routers.dashboard.service" = "api@internal";
        };

        environmentFiles = [ config.sops.templates."traefik-env".path ];

        extraOptions = [
          "--health-cmd=traefik healthcheck --ping"
          "--health-timeout=5s"
          "--health-start-period=10s"
        ];
      };

      systemd = {
        services.podman-traefik = {
          after = [ "zfs-mount.service" ];
          unitConfig.AssertPathIsMountPoint = "/srv/services/traefik";
          partOf = [ "podman-socket-proxy.service" ];
        };

        tmpfiles.rules = [ "d /srv/services/traefik 0700 root root -" ];
      };

      sops = {
        secrets."services/acme/scaleway-secret-key" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."traefik-env" = {
          content = ''
            SCW_SECRET_KEY=${config.sops.placeholder."services/acme/scaleway-secret-key"}
          '';
          restartUnits = [ "podman-traefik.service" ];
        };
      };
    };
}
