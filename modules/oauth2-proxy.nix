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
          reverseProxy = true;
          setXauthrequest = true;
          httpAddress = "http://127.0.0.1:4180";
          email.domains = [ "*" ];
          cookie.domain = ".shrimphouse.xyz";

          nginx.domain = "auth.shrimphouse.xyz";

          extraConfig = {
            code-challenge-method = "S256";
            oidc-issuer-url = "https://idm.shrimphouse.xyz/oauth2/openid/oauth2-proxy";
            scope = "openid email profile groups";
            skip-provider-button = true;
            trusted-proxy-ip = "127.0.0.1";
            whitelist-domain = ".shrimphouse.xyz";
          };

          clientSecretFile = config.sops.secrets."services/oauth2-proxy/client-secret".path;
          cookie.secretFile = config.sops.secrets."services/oauth2-proxy/cookie-secret".path;
        };

        nginx.virtualHosts."auth.shrimphouse.xyz" = {
          useACMEHost = "auth.shrimphouse.xyz";
          forceSSL = true;
          locations."/".return = "302 https://idm.shrimphouse.xyz";
        };
      };

      sops.secrets."services/oauth2-proxy/client-secret" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        owner = "oauth2-proxy";
      };

      sops.secrets."services/oauth2-proxy/cookie-secret" = {
        sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        owner = "oauth2-proxy";
      };

      systemd.services.oauth2-proxy = {
        after = [ "kanidm.service" ];
        requires = [ "kanidm.service" ];
      };

      security.acme.certs."auth.shrimphouse.xyz".group = "nginx";
    };
}
