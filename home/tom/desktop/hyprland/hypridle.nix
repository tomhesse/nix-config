{ lib, pkgs, ... }:
let
  brightnessctl = lib.getExe pkgs.brightnessctl;
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  hyprlock = lib.getExe pkgs.hyprlock;
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  pidof = lib.getExe' pkgs.procps "pidof";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pidof} hyprlock >/dev/null || ${hyprlock}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
      };
      listener = [
        {
          timeout = 150;
          on-timeout = "${brightnessctl} -s set 10";
          on-resume = "${brightnessctl} -r";
        }
        {
          timeout = 150;
          on-timeout = "${brightnessctl} -sd *:kbd_backlight set 0";
          on-resume = "${brightnessctl} -rd *:kbd_backlight";
        }
        {
          timeout = 300;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 330;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on && ${brightnessctl} -r";
        }
        {
          timeout = 1800;
          on-timeout = "${systemctl} suspend";
        }
      ];
    };
  };
}
