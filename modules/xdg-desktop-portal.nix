{
  flake.modules.nixos.xdg-desktop-portal = {
    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };

  flake.modules.homeManager.xdg-desktop-portal =
    { config, pkgs, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/xdg-desktop-portal-termfilechooser"
      ];

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
        config.hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        };
      };

      xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        default_dir=$HOME
        create_help_file=0
        env=TERMCMD=${pkgs.kitty}/bin/kitty --title termfilechooser
        open_mode=suggested
        save_mode=last
      '';
    };
}
