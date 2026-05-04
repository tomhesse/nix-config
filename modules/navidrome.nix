{
  flake.modules.nixos.navidrome =
    { config, lib, ... }:
    {
      services = {
        navidrome = {
          enable = true;
          settings = {
            Address = "127.0.0.1";
            Port = 4533;
            MusicFolder = "/srv/media/music";
            EnableUserEditing = false;
            EnableDownloads = false;
            ExtAuth.TrustedSources = "127.0.0.1/32";
            ExtAuth.LogoutURL = "https://idm.shrimphouse.xyz/ui/logout";
            Plugins.Enabled = false;
          };
          environmentFile = config.sops.templates."navidrome-env".path;
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

      sops = {
        secrets."services/navidrome/lastfm-api-key" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };
        secrets."services/navidrome/lastfm-api-secret" = {
          sopsFile = ./hosts/${config.networking.hostName}/secrets/nixos.yaml;
        };

        templates."navidrome-env" = {
          content = ''
            ND_LASTFM_APIKEY=${config.sops.placeholder."services/navidrome/lastfm-api-key"}
            ND_LASTFM_SECRET=${config.sops.placeholder."services/navidrome/lastfm-api-secret"}
          '';
          restartUnits = [ "navidrome.service" ];
        };
      };

      security.acme.certs."music.shrimphouse.xyz".group = "nginx";
    };
}
