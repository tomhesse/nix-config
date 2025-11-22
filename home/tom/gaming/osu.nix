{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  enabled = config.homeSpec.gaming.osu.enable;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  options.homeSpec.gaming.osu.enable = mkEnableOption "Enable installation of osu.";

  config = mkIf enabled {
    home.packages = [ pkgs.osu-lazer-bin ];

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeDataHome}/osu"
        ];
      };
    };
  };
}
