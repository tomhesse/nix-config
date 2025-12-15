{
  config,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib)
    concatMap
    filter
    mkIf
    optionalAttrs
    ;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;
in
{
  wayland.windowManager.hyprland = mkIf enabled {
    enable = true;
    settings = {
      decoration = {
        rounding = 8;
        shadow = {
          enabled = false;
        };
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      general = {
        border_size = 2;
        gaps_out = 10;
        layout = "master";
      }
      // optionalAttrs config.homeSpec.theme.catppuccin.enable {
        "col.active_border" = "$mauve";
        "col.inactive_border" = "$surface0";
      };
      input = {
        follow_mouse = 1;
      };
      master = {
        new_status = "master";
      };
      monitor = map (
        monitor:
        "${monitor.name},${
          if monitor.enabled then
            "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate},${monitor.position},${toString monitor.scale},transform,${toString monitor.rotation}"
          else
            "disable"
        }"
      ) config.homeSpec.monitors;
      misc = {
        disable_hyprland_logo = true; # Default wallpapers
        disable_splash_rendering = true; # Funny bottom text
        font_family = "Fira Sans";
      };
      workspace =
        concatMap (
          monitor:
          map (
            workspace:
            "${workspace},monitor:${monitor.name}${
              if monitor.defaultWorkspace == workspace then ",default:true" else ""
            }"
          ) monitor.workspaces
        ) (filter (monitor: monitor.enabled && monitor.workspaces != [ ]) config.homeSpec.monitors)
        ++ [ "10, border:false, rounding:false" ];
    };
  };
}
