{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) getExe' mkIf;

  gpgConnectAgent = getExe' pkgs.gnupg "gpg-connect-agent";

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
        gpgkick = ''${gpgConnectAgent} "scd serialno" "learn --force" /bye'';
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
