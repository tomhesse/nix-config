{
  flake.modules.homeManager.mpd =
    { config, lib, ... }:
    {
      home.persistence."/persistent".directories = [
        (lib.removePrefix "${config.home.homeDirectory}/" config.services.mpd.dataDir)
      ];

      services = {
        mpd = {
          enable = true;
          extraConfig = ''
            audio_output {
              type "pipewire"
              name "PipeWire"
            }

            restore_paused "yes"
          '';
          network.startWhenNeeded = true;
        };

        mpd-discord-rpc = {
          enable = true;
          settings.hosts = [
            "${config.services.mpd.network.listenAddress}:${toString config.services.mpd.network.port}"
          ];
        };

        mpdris2.enable = true;

        mpdscribble = {
          enable = true;
          endpoints."last.fm" = {
            username = "anusbauer";
            passwordFile = config.sops.secrets."services/lastfm/password".path;
          };
        };
      };

      sops.secrets."services/lastfm/password" = { };
    };
}
