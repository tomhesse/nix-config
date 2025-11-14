{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  services.hyprpaper = mkIf enabled {
    enable = true;
    settings = {
      preload = config.homeSpec.wallpaper;
      wallpaper = ", ${config.homeSpec.wallpaper}";
    };
  };
}
