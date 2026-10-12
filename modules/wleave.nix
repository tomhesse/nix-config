{
  flake.modules.homeManager.wleave =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe getExe';

      loginctl = getExe' pkgs.systemd "loginctl";
      systemctl = getExe' pkgs.systemd "systemctl";
      uwsm = getExe pkgs.uwsm;
      wleave = getExe config.programs.wleave.package;
    in
    {
      # catppuccin styles the buttons by label, so the layout sets no icons
      programs.wleave = {
        enable = true;
        settings = {
          close-on-lost-focus = true;
          show-keybinds = true;
          no-version-info = true;
          buttons = [
            {
              label = "shutdown";
              action = "${systemctl} poweroff";
              text = "Shutdown";
              keybind = "s";
            }
            {
              label = "reboot";
              action = "${systemctl} reboot";
              text = "Reboot";
              keybind = "r";
            }
            {
              label = "suspend";
              action = "${systemctl} suspend";
              text = "Suspend";
              keybind = "u";
            }
            {
              label = "logout";
              action = "${uwsm} stop";
              text = "Logout";
              keybind = "e";
            }
            {
              label = "lock";
              action = "${loginctl} lock-session";
              text = "Lock";
              keybind = "l";
            }
          ];
        };
      };

      programs.niri.settings.binds."Mod+Shift+E".action.spawn = [
        uwsm
        "app"
        "--"
        wleave
      ];
    };
}
