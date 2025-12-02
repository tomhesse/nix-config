{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
in
{
  home.packages = [ pkgs.obsidian ];

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeConfigHome}/obsidian"
      ];
    };
  };
}
