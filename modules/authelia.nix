{
  flake.modules.nixos.authelia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = "shrimphouse.xyz";
      baseDN = "dc=shrimphouse,dc=xyz";

      yaml = pkgs.formats.yaml { };

      configuration = yaml.generate "configuration.yml" {
        theme = "dark";

        log.level = "info";

        server = {
          address = "tcp://0.0.0.0:9091/";
          disable_healthcheck = true;
        };

        totp.issuer = domain;

        definitions.user_attributes = config.authelia.userAttributes;

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
              domain = lib.sort lib.lessThan config.authelia.adminDomains;
              subject = [ "group:admins" ];
              policy = "two_factor";
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

      oidcConfiguration = pkgs.writeText "oidc.yml" ''
        identity_providers:
          oidc:
            jwks:
              - key: {{ secret "/secrets/oidc-jwks.pem" | mindent 10 "|" | msquote }}

            authorization_policies:
              admins:
                default_policy: 'deny'
                rules:
                  - policy: 'two_factor'
                    subject:
                      - 'group:admins'

              household:
                default_policy: 'one_factor'
                rules:
                  - policy: 'two_factor'
                    subject:
                      - 'group:admins'
      '';

      oidcClients = yaml.generate "oidc-clients.yml" {
        identity_providers.oidc = {
          claims_policies = config.authelia.oidc.claimsPolicies;
          scopes = config.authelia.oidc.scopes;
          clients = lib.mapAttrsToList (
            id: client: { client_id = id; } // client
          ) config.authelia.oidc.clients;
        };
      };
    in
    {
      options.authelia = {
        adminDomains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Hostnames that require two-factor authentication for the admins group.";
        };

        userAttributes = lib.mkOption {
          inherit (yaml) type;
          default = { };
          description = "Custom user attributes, rendered into definitions.user_attributes.";
        };

        oidc = {
          clients = lib.mkOption {
            type = lib.types.attrsOf yaml.type;
            default = { };
            description = "OIDC clients keyed by client_id, in Authelia's own snake_case schema.";
          };

          claimsPolicies = lib.mkOption {
            inherit (yaml) type;
            default = { };
            description = "Custom claims policies, rendered into identity_providers.oidc.claims_policies.";
          };

          scopes = lib.mkOption {
            inherit (yaml) type;
            default = { };
            description = "Custom scopes, rendered into identity_providers.oidc.scopes.";
          };
        };
      };

      config = {
        virtualisation.oci-containers.containers.authelia = {
          image = "ghcr.io/authelia/authelia:4.39.28";

          entrypoint = "authelia";
          cmd = [
            "--config"
            "/config/configuration.yml"
            "--config"
            "/config/oidc.yml"
            "--config"
            "/config/oidc-clients.yml"
          ];

          dependsOn = [ "lldap" ];
          networks = [ "edge" ];

          volumes = [
            "${configuration}:/config/configuration.yml:ro"
            "${oidcConfiguration}:/config/oidc.yml:ro"
            "${oidcClients}:/config/oidc-clients.yml:ro"
            "${config.sops.secrets."services/authelia/oidc-jwks-key".path}:/secrets/oidc-jwks.pem:ro"
            "/srv/services/authelia:/data"
          ];

          environment.X_AUTHELIA_CONFIG_FILTERS = "template";

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
              '';
              restartUnits = [ "podman-authelia.service" ];
            };
          };
      };
    };
}
