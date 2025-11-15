{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeStateHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.stateHome;
in
{
  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeStateHome}/wireplumber"
      ];
    };
  };
}
