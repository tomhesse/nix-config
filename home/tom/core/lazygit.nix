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
  programs.lazygit = {
    enable = true;
    settings = {
      gui.mouseEvents = false;
    };
  };

  home.persistence = mkIf impermanenceEnabled {
    "/persist${config.home.homeDirectory}" = {
      files = [
        "${relativeStateHome}/lazygit/state.yml"
      ];
    };
  };
}
