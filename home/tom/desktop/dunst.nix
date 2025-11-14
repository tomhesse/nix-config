{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  services.dunst = mkIf enabled {
    enable = true;
    settings = {
      global = {
        corner_radius = 8;
        font = "Fira Sans 12";
        offset = "0x50";
        origin = "top-center";
      };
    };
  };
}
