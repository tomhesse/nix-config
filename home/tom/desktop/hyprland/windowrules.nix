{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  wayland.windowManager.hyprland = mkIf enabled {
    settings = {
      windowrule = [
        "float, class:org.pulseaudio.pavucontrol"
        "opacity 0.95, focus:0"
        "opacity 1.00, focus:1"
      ];
    };
  };
}
