{
  flake.modules.homeManager.swayidle =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe getExe';

      brightnessctl = getExe pkgs.brightnessctl;
      loginctl = getExe' pkgs.systemd "loginctl";
      niri = getExe pkgs.niri;
      swaylock = getExe config.programs.swaylock.package;
      systemctl = getExe' pkgs.systemd "systemctl";
      uwsm = getExe pkgs.uwsm;
    in
    {
      services.swayidle = {
        enable = true;
        # uwsm names the instance after the compositor binary, and systemd escapes
        # the hyphen: `niri-session` becomes `niri\x2dsession`
        systemdTargets = [ ''wayland-session@niri\x2dsession.target'' ];

        events = {
          lock = "${uwsm} app -- ${swaylock}";
          before-sleep = "${swaylock} -f";
        };

        timeouts = [
          {
            timeout = 150;
            command = "${brightnessctl} -s set 10% && ${brightnessctl} -sd '*kbd_backlight' set 0%";
            resumeCommand = "${brightnessctl} -r && ${brightnessctl} -d '*kbd_backlight' -r";
          }
          {
            timeout = 300;
            command = "${loginctl} lock-session";
          }
          {
            # niri has no "power on" action; any input wakes the outputs
            timeout = 330;
            command = "${niri} msg action power-off-monitors";
          }
          {
            timeout = 1800;
            command = "${systemctl} suspend";
          }
        ];
      };
    };
}
