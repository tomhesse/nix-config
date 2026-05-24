{
  flake.modules.nixos.grocy =
    { config, lib, ... }:
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

          locations = {
            "~ ^/api/" = {
              root = "${config.services.grocy.package}/public";
              extraConfig = ''
                auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
                error_page 401 = @api_noauth;

                fastcgi_pass unix:${config.services.phpfpm.pools.grocy.socket};
                include ${config.services.nginx.package}/conf/fastcgi.conf;
                include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root/index.php;
                fastcgi_param SCRIPT_NAME /index.php;
                fastcgi_param HTTP_REMOTE_USER $preferred_username;
              '';
            };

            "@api_noauth" = {
              root = "${config.services.grocy.package}/public";
              extraConfig = ''
                auth_request off;
                fastcgi_pass unix:${config.services.phpfpm.pools.grocy.socket};
                include ${config.services.nginx.package}/conf/fastcgi.conf;
                include ${config.services.nginx.package}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root/index.php;
                fastcgi_param SCRIPT_NAME /index.php;
              '';
            };

            "= /logout".return =
              "307 https://auth.shrimphouse.xyz/oauth2/sign_out?rd=https://idm.shrimphouse.xyz/ui/logout";

            "~ \\.php$".extraConfig = lib.mkAfter ''
              auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
              fastcgi_param HTTP_REMOTE_USER $preferred_username;
            '';
          };
        };
      };

      security.acme.certs."grocy.shrimphouse.xyz".group = "nginx";
    };
}
