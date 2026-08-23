{
  flake.modules.homeManager.hypridle =
    { lib, pkgs, ... }:
    let
      inherit (lib) getExe getExe';

      brightnessctl = getExe pkgs.brightnessctl;
      hyprctl = getExe' pkgs.hyprland "hyprctl";
      hyprlock = getExe pkgs.hyprlock;
      loginctl = getExe' pkgs.systemd "loginctl";
      systemctl = getExe' pkgs.systemd "systemctl";
      uwsm = getExe pkgs.uwsm;
    in
    {
      services.hypridle = {
        enable = true;
        systemdTarget = "wayland-session@hyprland.desktop.target";
        settings = {
          general = {
            lock_cmd = "${uwsm} app -- ${hyprlock}";
            before_sleep_cmd = "${loginctl} lock-session";
            after_sleep_cmd = "${hyprctl} dispatch dpms on";
          };
          listener = [
            {
              timeout = 150;
              on-timeout = "${brightnessctl} -s set 10% && ${brightnessctl} -sd '*kbd_backlight' set 0%";
              on-resume = "${brightnessctl} -r && ${brightnessctl} -d '*kbd_backlight' -r";
            }
            {
              timeout = 300;
              on-timeout = "${loginctl} lock-session";
            }
            {
              timeout = 330;
              on-timeout = "${hyprctl} dispatch dpms off";
              on-resume = "${hyprctl} dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "${systemctl} suspend";
            }
          ];
        };
      };
    };
}
