{
  config,
  inputs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  cfg = config.homeSpec.theme;
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  options.homeSpec.theme.catppuccin.enable = mkOption {
    type = types.bool;
    default = osConfig.hostSpec.theme.catppuccin.enable;
    description = "Enable catppucin theme for home-manager modules.";
  };

  config.catppuccin = mkIf cfg.catppuccin.enable {
    enable = true;
  };
}
