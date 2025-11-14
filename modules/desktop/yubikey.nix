{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.hostSpec.desktop;
in
{
  services.pcscd = mkIf cfg.enable {
    enable = true;
  };
}
