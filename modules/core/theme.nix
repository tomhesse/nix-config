{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.hostSpec.theme;
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  options.hostSpec.theme.catppuccin.enable = mkEnableOption "Enable catppuccin theme.";

  config = mkIf cfg.catppuccin.enable {
    catppuccin.enable = true;
  };
}
