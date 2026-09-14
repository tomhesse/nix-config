{
  flake.modules.nixos.lldap =
    { config, lib, ... }:
    let
      domain = "shrimphouse.xyz";
      baseDN = "dc=shrimphouse,dc=xyz";

      uid = 440;
    in
    {
      virtualisation.oci-containers.containers.lldap = {
        image = "docker.io/lldap/lldap:2026-08-28-alpine-rootless";

        networks = [ "edge" ];

        user = "${toString uid}:${toString uid}";

        volumes = [ "/srv/services/lldap:/data" ];

        environment = {
          LLDAP_HTTP_URL = "https://users.${domain}";
          LLDAP_KEY_FILE = "";
          LLDAP_LDAP_BASE_DN = baseDN;
          LLDAP_LDAP_USER_DN = "admin";
          LLDAP_LDAP_USER_EMAIL = "admin@${domain}";
          LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
          LLDAP_SMTP_OPTIONS__SERVER = "smtp.tem.scaleway.com";
          LLDAP_SMTP_OPTIONS__PORT = "465";
          LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = "TLS";
          LLDAP_SMTP_OPTIONS__USER = "608deeb4-b226-44f7-bb38-4354d8029c7e";
          LLDAP_SMTP_OPTIONS__FROM = "LLDAP <mimir@mail.${domain}>";
        };

        environmentFiles = [ config.sops.templates."lldap-env".path ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.lldap.rule" = "Host(`users.${domain}`)";
          "traefik.http.services.lldap.loadbalancer.server.port" = "17170";
        };

        podman.sdnotify = "healthy";

        capabilities.ALL = false;

        extraOptions = [
          "--read-only"
          "--security-opt=no-new-privileges"
          "--health-cmd=/app/lldap healthcheck --config-file /data/lldap_config.toml"
          "--health-interval=10s"
          "--health-timeout=3s"
          "--health-start-period=10s"
        ];
      };

      users = {
        groups.lldap.gid = uid;

        users.lldap = {
          isSystemUser = true;
          group = "lldap";
          inherit uid;
        };
      };

      systemd = {
        services.podman-lldap = {
          after = [ "zfs-mount.service" ];
          unitConfig.AssertPathIsMountPoint = "/srv/services/lldap";
          serviceConfig.TimeoutStartSec = lib.mkForce 120;
        };

        tmpfiles.rules = [ "d /srv/services/lldap 0700 lldap lldap -" ];
      };

      sops =
        let
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        in
        {
          secrets = {
            "services/lldap/jwt-secret" = { inherit sopsFile; };
            "services/lldap/key-seed" = { inherit sopsFile; };
            "services/lldap/admin-password" = { inherit sopsFile; };
            "services/lldap/smtp-password" = { inherit sopsFile; };
          };

          templates."lldap-env" = {
            content = ''
              LLDAP_JWT_SECRET=${config.sops.placeholder."services/lldap/jwt-secret"}
              LLDAP_KEY_SEED=${config.sops.placeholder."services/lldap/key-seed"}
              LLDAP_LDAP_USER_PASS=${config.sops.placeholder."services/lldap/admin-password"}
              LLDAP_SMTP_OPTIONS__PASSWORD=${config.sops.placeholder."services/lldap/smtp-password"}
            '';
            restartUnits = [ "podman-lldap.service" ];
          };
        };
    };
}
