{ lib, osConfig, ... }:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  programs.rofi = mkIf enabled {
    enable = true;
    font = "Fira Sans 12";
    extraConfig = {
      run-command = "uwsm app -- {cmd}";
      kb-row-up = "Up,Alt+k";
      kb-row-down = "Down,Alt+j";
    };
  };
}
