{
  config,
  inputs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;

  enabled = osConfig.hostSpec.impermanence.enable;
in
{
  imports = [ inputs.impermanence.homeManagerModules.impermanence ];

  config = mkIf enabled {
    home.persistence."/persist${config.home.homeDirectory}" = {
      allowOther = true;
    };
  };
}
