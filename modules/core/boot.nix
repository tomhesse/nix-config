{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;

  cfg = config.hostSpec.boot;
in
{
  options.hostSpec.boot.secureBoot.enable =
    mkEnableOption "Enable secure boot on the host (requires enrolled and created keys).";

  config = {
    boot = {
      loader = {
        limine = {
          enable = true;
          enableEditor = false;
          maxGenerations = 10;
          secureBoot.enable = cfg.secureBoot.enable;
        };
        efi.canTouchEfiVariables = true;
      };
      initrd.systemd.enable = true;
    };

    environment.persistence."/persist".directories = [
      "/var/lib/sbctl"
    ];
  };
}
