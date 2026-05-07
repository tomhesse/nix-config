{
  flake.modules.nixos.grocy =
    { lib, ... }:
    {
      services = {
        grocy = {
          enable = true;
          hostName = "grocy.shrimphouse.xyz";
          nginx.enableSSL = false;

          settings = {
            currency = "EUR";
            calendar.firstDayOfWeek = 1;
          };

          extraConfig = ''
            Setting('AUTH_CLASS', 'Grocy\Middleware\ReverseProxyAuthMiddleware');
            Setting('REVERSE_PROXY_AUTH_HEADER', 'HTTP_REMOTE_USER');
          '';
        };

        oauth2-proxy.nginx.virtualHosts."grocy.shrimphouse.xyz" = { };

        nginx.virtualHosts."grocy.shrimphouse.xyz" = {
          useACMEHost = "grocy.shrimphouse.xyz";
          forceSSL = true;

          locations."~ \\.php$".extraConfig = lib.mkAfter ''
            auth_request /oauth2/auth;
            error_page 401 = /oauth2/sign_in;

            auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
            fastcgi_param HTTP_REMOTE_USER $preferred_username;

            auth_request_set $auth_cookie $upstream_http_set_cookie;
            add_header Set-Cookie $auth_cookie;
          '';
        };
      };

      security.acme.certs."grocy.shrimphouse.xyz".group = "nginx";
    };
}
