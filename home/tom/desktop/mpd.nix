{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  sops.secrets."services/lastfm/password".sopsFile = ../hosts/secrets.yaml;

  services = {
    mpd = {
      enable = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
        restore_paused "yes"
      '';
    };

    mpdris2.enable = true;

    mpdscribble = {
      enable = true;
      endpoints."last.fm" = {
        username = "tomhesse";
        passwordFile = config.sops.secrets."services/lastfm/password".path;
      };
    };
  };

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeDataHome}/mpd"
      ];
    };
  };
}
