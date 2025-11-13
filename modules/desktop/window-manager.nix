{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.desktop;
in
{
  options.hostSpec.desktop.window-manager.hyprland.enable =
    mkEnableOption "Enable Hyprland window manager on the system.";

  config = mkIf cfg.enable {
    programs.hyprland = mkIf cfg.window-manager.hyprland.enable {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };
}
