{
  flake.modules.nixos.navidrome =
    { config, ... }:
    {
      services = {
        navidrome = {
          enable = true;
          settings = {
            Address = "127.0.0.1";
            BaseUrl = "https://navidrome.shrimphouse.xyz";
            Port = 4533;
            MusicFolder = "/srv/media/music";
            EnableUserEditing = false;
            EnableDownloads = false;
            EnableStarRating = false;
            Plugins.Enabled = false;
            Scanner.PurgeMissing = "always";
          };
          environmentFile = config.sops.templates."navidrome-env".path;
        };

        nginx.virtualHosts."navidrome.shrimphouse.xyz" = {
          useACMEHost = "navidrome.shrimphouse.xyz";
          forceSSL = true;

          locations."/".proxyPass = "http://127.0.0.1:4533";
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

      security.acme.certs."navidrome.shrimphouse.xyz".group = "nginx";
    };
}
