{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.shells.fish.enable or false;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  config = mkIf enabled {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
      '';
      shellAbbrs = {
        gpgkick = ''gpg-connect-agent "scd serialno" "learn --force" /bye'';
      };
    };

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeDataHome}/fish"
        ];
      };
    };
  };
}
