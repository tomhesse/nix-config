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
  };

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeDataHome}/mpd"
      ];
    };
  };
}
