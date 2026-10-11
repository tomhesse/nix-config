{
  flake.modules.homeManager.swaync =
    { lib, pkgs, ... }:
    let
      swaync-client = lib.getExe' pkgs.swaynotificationcenter "swaync-client";
    in
    {
      services.swaync = {
        enable = true;

        settings = {
          control-center-margin-top = 10;
          control-center-margin-right = 10;
          control-center-margin-bottom = 10;
          notification-window-width = 400;
        };
      };

      catppuccin.swaync.font = "Fira Sans";

      programs.niri.settings.binds."Mod+N".action.spawn = [
        swaync-client
        "-t"
        "-sw"
      ];
    };
}
