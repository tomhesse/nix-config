{ hmConfig, lib, ... }:
let
  inherit (lib) mkIf;

  hyprlandEnabled = hmConfig.wayland.windowManager.hyprland.enable;
in
{
  clipboard.providers = {
    wl-copy = mkIf hyprlandEnabled {
      enable = true;
    };
  };
}
