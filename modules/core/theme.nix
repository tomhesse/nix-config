{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.hostSpec.theme;
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  options.hostSpec.theme.catppuccin = {
    enable = mkEnableOption "Enable catppuccin theme.";
    fontSize = mkOption {
      type = types.str;
      default = "12";
      description = "Font size used by different catppuccin ports.";
    };
  };

  config = mkIf cfg.catppuccin.enable {
    catppuccin.enable = true;
  };
}
