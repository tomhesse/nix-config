{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.hostSpec.desktop;
in
{
  config = mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
}
