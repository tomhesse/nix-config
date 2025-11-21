{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.gaming.steam.enable;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  config = mkIf enabled {
    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeDataHome}/Steam"
        ];
      };
    };
  };
}
