{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;

  cfg = config.hostSpec.zram;
in
{
  options.hostSpec.zram.enable = mkEnableOption "Enable zram.";

  config.zramSwap.enable = cfg.enable;
}
