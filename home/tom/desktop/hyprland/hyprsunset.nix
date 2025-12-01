{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  services.hyprsunset = mkIf enabled {
    enable = true;
    settings = {
      profile = [
        {
          time = "7:30";
          temperature = 5800;
        }
        {
          time = "12:00";
          temperature = 6500;
        }
        {
          time = "18:30";
          temperature = 5200;
        }
        {
          time = "21:30";
          temperature = 4100;
        }
        {
          time = "23:30";
          temperature = 3500;
        }
      ];
    };
  };
}
