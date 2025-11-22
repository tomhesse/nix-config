{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  enabled = osConfig.hostSpec.gaming.steam.enable;
  impermanenceEnabled = osConfig.hostSpec.impermanence.enable;

  cfg = config.homeSpec.gaming.steam;

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
  options.homeSpec.gaming.steam.autostart = mkEnableOption "Autostart steam on login.";

  config = mkIf enabled {
    xdg.autostart.entries = mkIf cfg.autostart [
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
