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
    flavor = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
      description = "Flavor used by different catppuccin ports.";
    };
    accent = mkOption {
      type = types.enum [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      default = "mauve";
      description = "Accent used by different catppuccin ports.";
    };
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
