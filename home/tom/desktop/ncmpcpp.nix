{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (config.xdg) dataHome;

  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;
in
{
  programs.ncmpcpp = {
    enable = true;
    settings = {
      lyrics_directory = "${dataHome}/lyrics";
      ncmpcpp_directory = "${dataHome}/ncmpcpp";
    };
  };

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      directories = [
        "${relativeDataHome}/lyrics"
        "${relativeDataHome}/ncmpcpp"
      ];
    };
  };
}
