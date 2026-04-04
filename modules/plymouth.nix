{
  flake.modules.nixos.plymouth =
    { pkgs, ... }:
    {
      boot = {
        plymouth = {
          enable = true;
          font = "${pkgs.fira-sans}/share/fonts/opentype/FiraSans-Regular.otf";
          logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
        };

        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "systemd.show_status=auto"
        ];

        loader.timeout = 0;
      };
    };
}
