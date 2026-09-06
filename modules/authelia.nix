{
  flake.modules.nixos.authelia =
    { config, pkgs, ... }:
    let
      domain = "shrimphouse.xyz";
      baseDN = "dc=shrimphouse,dc=xyz";

      configuration = (pkgs.formats.yaml { }).generate "configuration.yml" {
        theme = "dark";

        log.level = "info";

        server = {
          address = "tcp://0.0.0.0:9091/";
          disable_healthcheck = true;
        };

        totp.issuer = domain;

        authentication_backend = {
          password_change.disable = true;
          password_reset.custom_url = "https://users.${domain}/reset-password/step1";

          ldap = {
            implementation = "lldap";
            address = "ldap://lldap:3890";
            base_dn = baseDN;
            user = "uid=authelia,ou=people,${baseDN}";
            users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person)(memberOf=cn=users,ou=groups,${baseDN}))";
          };
        };

        access_control = {
          default_policy = "deny";

          rules = [
            {
              domain = [
                "bazarr.${domain}"
                "prowlarr.${domain}"
                "radarr.${domain}"
                "sabnzbd.${domain}"
                "sonarr.${domain}"
              ];
              subject = [ "group:admins" ];
              policy = "two_factor";
            }
            {
              domain = [ "traefik.${domain}" ];
              subject = [ "group:admins" ];
              policy = "two_factor";
            }
          ];
        };

        identity_providers.oidc = {
          authorization_policies.admins = {
            default_policy = "deny";

            rules = [
              {
                policy = "two_factor";
                subject = [ "group:admins" ];
              }
            ];
          };

          clients = [
            {
              client_id = "profilarr";
              client_name = "Profilarr";
              client_secret = "$pbkdf2-sha512$310000$G9hHaCv6996H5mh59hOpeQ$DpqK9caOIHpImo8d.PcMyOo9/yN3Cr/t31g.PjcoZHzlGqEnLdf5xTTUBaNDMR6mkkPBBN.Cj159YK.RwCeD0A";
              public = false;
              authorization_policy = "admins";
              consent_mode = "implicit";
              redirect_uris = [ "https://profilarr.${domain}/auth/oidc/callback" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
            }
          ];
        };

        session.cookies = [
          {
            inherit domain;
            authelia_url = "https://auth.${domain}";
          }
        ];

        storage.local.path = "/data/db.sqlite3";

        notifier.smtp = {
          address = "submissions://smtp.tem.scaleway.com:465";
          sender = "Authelia <mimir@mail.${domain}>";
        };
      };
    in
    {
      virtualisation.oci-containers.containers.authelia = {
        image = "ghcr.io/authelia/authelia:4.39.22";

        entrypoint = "authelia";
        cmd = [
          "--config"
          "/config/configuration.yml"
        ];

        dependsOn = [ "lldap" ];
        networks = [ "edge" ];

        volumes = [
          "${configuration}:/config/configuration.yml:ro"
          "${config.sops.secrets."services/authelia/oidc-jwks-key".path}:/secrets/oidc-jwks.pem:ro"
          "/srv/services/authelia:/data"
        ];

        environmentFiles = [ config.sops.templates."authelia-env".path ];

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.authelia.rule" = "Host(`auth.${domain}`)";
          "traefik.http.middlewares.authelia.forwardauth.address" =
            "http://authelia:9091/api/authz/forward-auth";
          "traefik.http.middlewares.authelia.forwardauth.trustforwardheader" = "true";
          "traefik.http.middlewares.authelia.forwardauth.authresponseheaders" =
            "Remote-User,Remote-Groups,Remote-Email,Remote-Name";
        };

        capabilities.ALL = false;

        extraOptions = [
          "--read-only"
          "--security-opt=no-new-privileges"
          "--health-cmd=wget --quiet --tries=1 --spider http://localhost:9091/api/health"
          "--health-timeout=3s"
          "--health-start-period=10s"
        ];
      };

      systemd = {
        services.podman-authelia = {
          after = [ "zfs-mount.service" ];
          unitConfig.AssertPathIsMountPoint = "/srv/services/authelia";
          partOf = [ "podman-lldap.service" ];
        };

        tmpfiles.rules = [ "d /srv/services/authelia 0700 root root -" ];
      };

      sops =
        let
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        in
        {
          secrets = {
            "services/authelia/session-secret" = { inherit sopsFile; };
            "services/authelia/storage-encryption-key" = { inherit sopsFile; };
            "services/authelia/reset-jwt-secret" = { inherit sopsFile; };
            "services/authelia/ldap-password" = { inherit sopsFile; };
            "services/authelia/oidc-hmac-secret" = { inherit sopsFile; };
            "services/authelia/oidc-jwks-key" = { inherit sopsFile; };
            "services/authelia/smtp-password" = { inherit sopsFile; };
          };

          templates."authelia-env" = {
            content = ''
              AUTHELIA_SESSION_SECRET=${config.sops.placeholder."services/authelia/session-secret"}
              AUTHELIA_STORAGE_ENCRYPTION_KEY=${
                config.sops.placeholder."services/authelia/storage-encryption-key"
              }
              AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET=${
                config.sops.placeholder."services/authelia/reset-jwt-secret"
              }
              AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD=${
                config.sops.placeholder."services/authelia/ldap-password"
              }
              AUTHELIA_NOTIFIER_SMTP_USERNAME=608deeb4-b226-44f7-bb38-4354d8029c7e
              AUTHELIA_NOTIFIER_SMTP_PASSWORD=${config.sops.placeholder."services/authelia/smtp-password"}
              AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET=${
                config.sops.placeholder."services/authelia/oidc-hmac-secret"
              }
              AUTHELIA_IDENTITY_PROVIDERS_OIDC_JWKS_0_KEY_FILE=/secrets/oidc-jwks.pem
            '';
            restartUnits = [ "podman-authelia.service" ];
          };
        };
    };
}
