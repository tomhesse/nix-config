{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.hostSpec.desktop;
in
{
  programs.yubikey-manager = mkIf cfg.enable {
    enable = true;
  };
}
