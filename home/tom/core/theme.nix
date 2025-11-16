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

  options.homeSpec.theme.catppuccin = {
    enable = mkOption {
      type = types.bool;
      default = osConfig.hostSpec.theme.catppuccin.enable;
      description = "Enable catppucin theme for home-manager modules.";
    };
    flavor = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = osConfig.hostSpec.theme.catppuccin.flavor;
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
      default = osConfig.hostSpec.theme.catppuccin.accent;
      description = "Accent used by different catppuccin ports.";
    };
  };

  config.catppuccin = mkIf cfg.catppuccin.enable {
    enable = true;
  };
}
