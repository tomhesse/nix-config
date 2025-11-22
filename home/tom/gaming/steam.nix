{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.gaming.steam.enable;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  relativeDataHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome;

  steamDesktop = pkgs.makeDesktopItem {
    name = "steam";
    desktopName = "Steam";
    exec = "steam -silent %U";
    icon = "steam";
    terminal = false;
    type = "Application";
    prefersNonDefaultGPU = true;
  };
in
{
  config = mkIf enabled {
    xdg.autostart.entries = [
      "${steamDesktop}/share/applications/steam.desktop"
    ];

    home.persistence = mkIf impermanenceEnabled {
      "/persist${config.home.homeDirectory}" = {
        directories = [
          "${relativeDataHome}/Steam"
        ];
      };
    };
  };
}
