{
  flake.modules.nixos.oauth2-proxy =
    { config, ... }:
    {
      services = {
        oauth2-proxy = {
          enable = true;
          provider = "oidc";
          clientID = "oauth2-proxy";
          redirectURL = "https://auth.shrimphouse.xyz/oauth2/callback";
          setXauthrequest = true;
          httpAddress = "http://127.0.0.1:4180";
          email.domains = [ "*" ];
          cookie.domain = ".shrimphouse.xyz";

          nginx.domain = "auth.shrimphouse.xyz";

          extraConfig = {
            code-challenge-method = "S256";
            trusted-ip = "127.0.0.1/32";
            oidc-issuer-url = "https://idm.shrimphouse.xyz/oauth2/openid/oauth2-proxy";
            whitelist-domain = ".shrimphouse.xyz";
            skip-provider-button = true;
          };

          keyFile = config.sops.templates."oauth2-proxy-env".path;
        };

        nginx.virtualHosts."auth.shrimphouse.xyz" = {
          useACMEHost = "auth.shrimphouse.xyz";
          forceSSL = true;
        };
      };

      sops = {
        secrets."services/oauth2-proxy/client-secret" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };
        secrets."services/oauth2-proxy/cookie-secret" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."oauth2-proxy-env" = {
          content = ''
            OAUTH2_PROXY_CLIENT_SECRET=${config.sops.placeholder."services/oauth2-proxy/client-secret"}
            OAUTH2_PROXY_COOKIE_SECRET=${config.sops.placeholder."services/oauth2-proxy/cookie-secret"}
          '';
          restartUnits = [ "oauth2-proxy.service" ];
        };
      };

      systemd.services.oauth2-proxy = {
        after = [ "kanidm.service" ];
        requires = [ "kanidm.service" ];
      };

      security.acme.certs."auth.shrimphouse.xyz".group = "nginx";
    };
}
