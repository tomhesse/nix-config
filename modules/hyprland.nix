{
  flake.modules.nixos.hyprland = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };

  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe getExe' optionalAttrs;
      inherit (osConfig) monitors;

      monitorId = name: m: if m.description != "" then "desc:${m.description}" else name;
      transform =
        m:
        {
          "normal" = "0";
          "90" = "1";
          "180" = "2";
          "270" = "3";
        }
        .${m.rotation};
      monitorLines = lib.mapAttrsToList (
        name: m:
        "${monitorId name m}, ${m.resolution}@${toString m.refreshRate}, ${toString m.position.x}x${toString m.position.y}, ${toString m.scale}, transform, ${transform m}"
      ) monitors;

      uwsm = getExe pkgs.uwsm;

      cliphist = getExe pkgs.cliphist;
      hyprlock = getExe pkgs.hyprlock;
      kitty = getExe pkgs.kitty;
      media-ctl = getExe pkgs.local.media-ctl;
      playerctl = getExe pkgs.playerctl;
      rofi = getExe pkgs.rofi;
      wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$mainMod" = "SUPER";
          decoration = {
            rounding = 8;
            shadow.enabled = false;
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
          // optionalAttrs config.catppuccin.enable {
            "col.active_border" = "$mauve";
            "col.inactive_border" = "$surface0";
          };
          input = {
            follow_mouse = 1;
          };
          master = {
            new_status = "master";
          };
          monitor = monitorLines ++ [ ", preferred, auto, 1" ];
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            font_family = "Fira Sans";
          };
          windowrule = [
            "opacity 0.95, focus:0"
            "opacity 1.00, focus:1"
          ];
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

            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            "$mainMod, comma, focusmonitor, -1"
            "$mainMod, period, focusmonitor, +1"
            "$mainMod SHIFT, comma, movewindow, mon:-1"
            "$mainMod SHIFT, period, movewindow, mon:+1"
          ];
          bindl = [
            ", XF86AudioMute, exec, ${uwsm} app -- ${media-ctl} volume mute"
            ", XF86AudioRaiseVolume, exec, ${uwsm} app -- ${media-ctl} volume up"
            ", XF86AudioLowerVolume, exec, ${uwsm} app -- ${media-ctl} volume down"
            ", XF86MonBrightnessUp, exec, ${uwsm} app -- ${media-ctl} brightness up"
            ", XF86MonBrightnessDown, exec, ${uwsm} app -- ${media-ctl} brightness down"
            ", XF86AudioPlay, exec, ${playerctl} play-pause"
            ", XF86AudioStop, exec, ${playerctl} stop"
            ", XF86AudioPrev, exec, ${playerctl} previous"
            ", XF86AudioNext, exec, ${playerctl} next"
          ];
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
      };
    };
}
