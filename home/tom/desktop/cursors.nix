{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf optionalAttrs;

  catppuccinEnabled = config.homeSpec.theme.catppuccin.enable;
in
{
  catppuccin = mkIf catppuccinEnabled {
    cursors.enable = true;
  };

  home.pointerCursor = {
    dotIcons.enable = false;
  }
  // optionalAttrs (!catppuccinEnabled) {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
  };
}
