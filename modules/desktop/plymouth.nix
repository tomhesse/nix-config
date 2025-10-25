{ pkgs, ... }:
{
  boot = {
    plymouth = {
      enable = true;
      font = "${pkgs.fira-sans}/share/fonts/opentype/FiraSans-Regular.otf";
      logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };
}
