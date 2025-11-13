{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.shells;
in
{
  options.hostSpec.shells.fish.enable = mkEnableOption "Enable fish shell.";

  config.programs = mkIf cfg.fish.enable {
    fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };

}
