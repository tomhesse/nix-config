{
  flake.modules.nixos.navidrome =
    { lib, ... }:
    {
      services = {
        navidrome = {
          enable = true;
          settings = {
            Address = "127.0.0.1";
            Port = 4533;
            MusicFolder = "/srv/media/music";
            ExtAuth.TrustedSources = "127.0.0.1/32";
          };
        };

        oauth2-proxy.nginx.virtualHosts."music.shrimphouse.xyz" = { };

        nginx.virtualHosts."music.shrimphouse.xyz" = {
          useACMEHost = "music.shrimphouse.xyz";
          forceSSL = true;

          locations = {
            "/".proxyPass = "http://127.0.0.1:4533";
            "/".extraConfig = lib.mkAfter ''
              auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
              proxy_set_header Remote-User $preferred_username;
            '';

            "/rest/" = {
              proxyPass = "http://127.0.0.1:4533";
              extraConfig = ''
                auth_request off;
              '';
            };
          };
        };
      };

      security.acme.certs."music.shrimphouse.xyz".group = "nginx";
    };
}
