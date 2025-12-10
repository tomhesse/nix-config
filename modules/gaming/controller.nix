{ config, lib, ... }:
let
  inherit (lib) mkIf;

  bluetoothEnabled = config.hostSpec.desktop.bluetooth.enable;

  gamingEnabled = config.hostSpec.gaming.enable;
in
{
  config = mkIf gamingEnabled {
    hardware = mkIf bluetoothEnabled {
      xpadneo.enable = true;
    };
  };
}
