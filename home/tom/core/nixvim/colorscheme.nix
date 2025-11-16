{ hmConfig, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = hmConfig.homeSpec.theme;
in
{
  colorschemes = {
    catppuccin = mkIf cfg.catppuccin.enable {
      enable = true;
      settings.flavour = cfg.catppuccin.flavor;
    };
  };
}
