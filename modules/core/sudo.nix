{ config, lib, ... }:
let
  inherit (lib) mkIf;

  impermanenceEnabled = config.hostSpec.impermanence.enable;
in
{
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  environment.persistence = mkIf impermanenceEnabled {
    "/persist".directories = [
      "/var/db/sudo/lectured"
    ];
  };
}
