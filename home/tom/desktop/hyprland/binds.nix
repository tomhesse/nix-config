{ pkgs, ... }:
{
  home.packages = builtins.attrValues { inherit (pkgs) playerctl; };

  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$locker" = "uwsm app -- hyprlock";
    "$menu" = "uwsm app -- rofi -show drun";
    "$terminal" = "uwsm app -- kitty";
    bind = [
      "$mainMod SHIFT, L, exec, $locker"
      "$mainMod, P, exec, $menu"
      "$mainMod SHIFT, RETURN, exec, $terminal"

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

      # Focus monitor and move window to monitor
      "$mainMod, comma, focusmonitor, -1"
      "$mainMod, period, focusmonitor, +1"
      "$mainMod SHIFT, comma, movewindow, mon:-1"
      "$mainMod SHIFT, period, movewindow, mon:+1"
    ];
    bindl = [
      ",XF86AudioMute, exec, ${pkgs.local.dunst-scripts}/bin/volume-mute"
      ",XF86AudioLowerVolume, exec, ${pkgs.local.dunst-scripts}/bin/volume-down"
      ",XF86AudioRaiseVolume, exec, ${pkgs.local.dunst-scripts}/bin/volume-up"
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86MonBrightnessUp, exec, ${pkgs.local.dunst-scripts}/bin/brightness-up"
      ",XF86MonBrightnessDown, exec, ${pkgs.local.dunst-scripts}/bin/brightness-down"
    ];
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
  };
}
