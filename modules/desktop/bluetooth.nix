{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.desktop.bluetooth;

  impermanenceEnabled = config.hostSpec.impermanence.enable;
in
{
  options.hostSpec.desktop.bluetooth.enable = mkEnableOption "Enable bluetooth on the system.";

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    environment.persistence = mkIf impermanenceEnabled {
      "/persist".directories = [
        {
          directory = "/var/lib/bluetooth";
          mode = "0700";
        }
      ];
    };
  };
}
