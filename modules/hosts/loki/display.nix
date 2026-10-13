{ self, ... }:
{
  configurations.nixos.loki.module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe mapAttrsToList;

      niri = getExe pkgs.niri;

      desk = removeAttrs config.monitors [ "eDP-1" ];

      kanshiOutput = name: m: {
        criteria = if m.description != "" then m.description else name;
        status = "enable";
        mode = "${m.resolution}@${toString m.refreshRate}Hz";
        position = "${toString m.position.x},${toString m.position.y}";
        scale = 1.0 * m.scale;
        transform = m.rotation;
      };
    in
    {
      imports = [ self.modules.nixos.desk-monitors ];

      home-manager.users.thesse = {
        wallpaper = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/k8/wallhaven-k899o7.png";
          sha256 = "sha256-36sgTh1D/8KQlLhx/ZfhwFyoXfO59JoOBZnJFPjligM=";
        };

        services.kanshi = {
          enable = true;
          systemdTarget = ''wayland-session@niri\x2dsession.target'';
          settings = [
            {
              profile = {
                name = "undocked";
                outputs = [ (kanshiOutput "eDP-1" config.monitors.eDP-1) ];
              };
            }
            {
              profile = {
                name = "docked";
                outputs = [
                  {
                    criteria = "eDP-1";
                    status = "disable";
                  }
                ]
                ++ mapAttrsToList kanshiOutput desk;
                exec = [ "${niri} msg action focus-monitor '${config.monitors.DP-1.description}'" ];
              };
            }
          ];
        };
      };

      monitors = {
        eDP-1 = {
          resolution = "2880x1920";
          refreshRate = 120;
          scale = 2;
          position.x = 560;
          position.y = 1440;
          primary = true;
        };
      };
    };
}
