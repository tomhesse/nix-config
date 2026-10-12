{
  flake.modules.nixos.swayosd =
    { pkgs, ... }:
    {
      services.dbus.packages = [ pkgs.swayosd ];
      systemd.packages = [ pkgs.swayosd ];
      systemd.services.swayosd-libinput-backend.wantedBy = [ "graphical.target" ];
    };

  flake.modules.homeManager.swayosd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      palette =
        (lib.importJSON "${config.catppuccin.sources.palette}/palette.json")
        .${config.catppuccin.flavor}.colors;
    in
    {
      services.swayosd = {
        enable = true;

        stylePath = pkgs.writeText "swayosd.css" ''
          window#osd {
            border-radius: 999px;
            border: 2px solid ${palette.surface0.hex};
            background: alpha(${palette.base.hex}, 0.9);
          }

          window#osd #container {
            margin: 16px;
          }

          window#osd image,
          window#osd label {
            color: ${palette.text.hex};
          }

          window#osd progressbar:disabled,
          window#osd image:disabled {
            opacity: 0.5;
          }

          window#osd progressbar,
          window#osd segmentedprogress {
            min-height: 6px;
            border-radius: 999px;
            background: transparent;
            border: none;
          }

          window#osd trough,
          window#osd segment {
            min-height: inherit;
            border-radius: inherit;
            border: none;
            background: ${palette.surface1.hex};
          }

          window#osd progress,
          window#osd segment.active {
            min-height: inherit;
            border-radius: inherit;
            border: none;
            background: ${palette.blue.hex};
          }

          window#osd segment {
            margin-left: 8px;
          }

          window#osd segment:first-child {
            margin-left: 0;
          }
        '';
      };
    };
}
