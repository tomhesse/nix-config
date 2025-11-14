{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = config.homeSpec.browser.firefox.enable;
in
{
  config = mkIf enabled {
    catppuccin.firefox.enable = false;
  };
}
