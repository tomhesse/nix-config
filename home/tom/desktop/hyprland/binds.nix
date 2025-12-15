{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mkIf
    ;

  enabled = osConfig.hostSpec.desktop.window-manager.hyprland.enable;

  uwsm = getExe pkgs.uwsm;

  cliphist = getExe pkgs.cliphist;
  hyprlock = getExe pkgs.hyprlock;
  kitty = getExe pkgs.kitty;
  rofi = getExe pkgs.rofi;
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";

  volume-mute = getExe' pkgs.local.dunst-scripts "volume-mute";
  volume-up = getExe' pkgs.local.dunst-scripts "volume-up";
  volume-down = getExe' pkgs.local.dunst-scripts "volume-down";
  brightness-up = getExe' pkgs.local.dunst-scripts "brightness-up";
  brightness-down = getExe' pkgs.local.dunst-scripts "brightness-down";
in
{
  config = mkIf enabled {
    wayland.windowManager.hyprland = {
      settings = {
        "$mainMod" = "SUPER";
        bind = [
          "$mainMod, V, exec, ${cliphist} list | ${uwsm} app -- ${rofi} -dmenu -display-columns 2 | ${cliphist} decode | ${wl-copy}"
          "$mainMod SHIFT, L, exec, ${uwsm} app -- ${hyprlock}"
          "$mainMod, P, exec, ${uwsm} app -- ${rofi} -show drun"
          "$mainMod SHIFT, RETURN, exec, ${uwsm} app -- ${kitty}"

          "$mainMod, j, layoutmsg, cyclenext"
          "$mainMod, k, layoutmsg, cycleprev"
          "$mainMod, i, layoutmsg, addmaster"
          "$mainMod, d, layoutmsg, removemaster"
          "$mainMod, h, layoutmsg, mfact -0.05"
          "$mainMod, l, layoutmsg, mfact +0.05"

          "$mainMod, RETURN, layoutmsg, swapwithmaster"

          "$mainMod SHIFT, C, killactive"

          "$mainMod, F, togglefloating"
          "$mainMod, M, fullscreen"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod, TAB, workspace, previous"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 10, movetoworkspace, 0"

          # Focus monitor and move window to monitor
          "$mainMod, comma, focusmonitor, -1"
          "$mainMod, period, focusmonitor, +1"
          "$mainMod SHIFT, comma, movewindow, mon:-1"
          "$mainMod SHIFT, period, movewindow, mon:+1"
        ];
        bindl = [
          ",XF86AudioMute, exec, ${uwsm} app -- ${volume-mute}"
          ",XF86AudioRaiseVolume, exec, ${uwsm} app -- ${volume-up}"
          ",XF86AudioLowerVolume, exec, ${uwsm} app -- ${volume-down}"
          ",XF86MonBrightnessUp, exec, ${uwsm} app -- ${brightness-up}"
          ",XF86MonBrightnessDown, exec, ${uwsm} app -- ${brightness-down}"
        ];
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
